import 'package:cloud_firestore/cloud_firestore.dart';
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
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return _mapDocumentToUser(doc);
    } catch (e) {
      // Handle error (e.g., network issues)
      rethrow;
    }
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    try {
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
  }) async {
    try {
      final updateData = <String, dynamic>{
        if (name != null) 'name': name,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .update(updateData);
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

  // Helper methods
  Map<String, dynamic> _mapUserToJson(UserEntity user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'createdAt': user.createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserEntity _mapDocumentToUser(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserEntity(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
