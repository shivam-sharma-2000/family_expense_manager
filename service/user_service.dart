import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/model/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> createUser({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
    String? familyId,
  }) async {
    // Generate a new family ID if not provided
    final userFamilyId = familyId ?? await _generateFamilyId();
    
    final user = UserModel(
      id: userId,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      totalExpense: 0.0,
      totalEarning: 0.0,
      familyId: userFamilyId,
    );

    await _firestore.collection('users').doc(userId).set(user.toMap());
  }

  Future<String> _generateFamilyId() async {
    // Generate a random 8-character alphanumeric string
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String familyId = '';
    
    do {
      familyId = '';
      for (int i = 0; i < 8; i++) {
        familyId += chars[(random * i) % chars.length];
      }
      // Check if family ID already exists
      final query = await _firestore
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .limit(1)
          .get();
      if (query.docs.isEmpty) break;
    } while (true);
    
    return familyId;
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!..['id'] = doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<bool> joinFamily(String userId, String familyId) async {
    try {
      // Check if family exists
      final query = await _firestore
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .limit(1)
          .get();
          
      if (query.docs.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          'familyId': familyId,
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error joining family: $e');
      return false;
    }
  }
}
