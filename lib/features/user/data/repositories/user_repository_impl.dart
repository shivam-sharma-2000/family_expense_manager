import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/features/expense/data/datasources/local/database_helper.dart';
import 'package:expense_manager/features/user/domain/entities/user_entity.dart';
import 'package:expense_manager/features/user/domain/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserRepositoryImpl(this._firestore, this._auth);

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return getUser(user.uid);
  }

  @override
  Future<UserEntity?> getUser(String userId) async {
    try {
      // 1. Try to fetch from local SQLite first
      final localData = await DatabaseHelper.instance.getUserLocally(userId);
      if (localData != null) {
        // 2. Fire background refresh
        _fetchAndCacheUser(userId);
        return _mapLocalDataToUser(localData);
      }

      // 3. If no local data, await Firebase fetch
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      
      final user = _mapDocumentToUser(doc);
      await DatabaseHelper.instance.saveUserLocally(_mapUserToLocalData(user));
      return user;
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> _fetchAndCacheUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final user = _mapDocumentToUser(doc);
        await DatabaseHelper.instance.saveUserLocally(_mapUserToLocalData(user));
      }
    } catch (e) {
      // Ignore background fetch errors
    }
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    try {
      // Save locally
      await DatabaseHelper.instance.saveUserLocally(_mapUserToLocalData(user));

      final userData = _mapUserToJson(user);
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      // Note: You might want to handle auth user deletion separately
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? photoUrl,
    String? familyId,
  }) async {
    try {
      // Update remote
      final updateData = <String, dynamic>{
        if (name != null) 'name': name,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (familyId != null) 'familyId': familyId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .update(updateData);
          
      // Update local
      final localData = <String, dynamic>{
        if (name != null) 'name': name,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (familyId != null) 'familyId': familyId,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await DatabaseHelper.instance.updateUserLocally(userId, localData);
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  @override
  Stream<UserEntity?> userDataChanges(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? _mapDocumentToUser(doc) : null);
  }

  @override
  Future<List<UserEntity>> getUsersByFamilyId(String familyId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();
      return snapshot.docs.map((doc) => _mapDocumentToUser(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Helper methods
  Map<String, dynamic> _mapUserToJson(UserEntity user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'familyId': user.familyId,
      'createdAt': user.createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _mapUserToLocalData(UserEntity user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'familyId': user.familyId,
      'createdAt': user.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': user.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  UserEntity _mapLocalDataToUser(Map<String, dynamic> data) {
    return UserEntity(
      id: data['id'],
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      familyId: data['familyId'],
      createdAt: data['createdAt'] != null ? DateTime.tryParse(data['createdAt']) : null,
      updatedAt: data['updatedAt'] != null ? DateTime.tryParse(data['updatedAt']) : null,
    );
  }

  UserEntity _mapDocumentToUser(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserEntity(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      familyId: data['familyId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
