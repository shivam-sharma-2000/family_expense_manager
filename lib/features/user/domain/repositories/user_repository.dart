import 'package:expense_manager/features/user/domain/entities/user_entity.dart';

abstract class UserRepository {
  // Get current user
  Future<UserEntity?> getCurrentUser();
  
  // Get user by ID
  Future<UserEntity?> getUser(String userId);
  
  // Create or update user
  Future<void> saveUser(UserEntity user);
  
  // Delete user
  Future<void> deleteUser(String userId);
  
  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? photoUrl,
  });
  
  // Stream of user data changes
  Stream<UserEntity?> userDataChanges(String userId);
}
