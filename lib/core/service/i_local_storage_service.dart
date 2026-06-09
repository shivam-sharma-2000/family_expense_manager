import '../enums/user_role.dart';

abstract interface class ILocalStorageService {
  // -------------------- 🔐 Authentication --------------------

  /// Saves the access token securely.
  Future<void> setAccessToken(String accessToken);

  /// Retrieves the stored access token.
  Future<String?> get accessToken;

  /// Saves the refresh token securely.
  Future<void> setRefreshToken(String refreshToken);

  /// Retrieves the stored refresh token.
  Future<String?> get refreshToken;

  Future<bool?> get isOnBoardingComplete;

  Future<void> setOnBoardingComplete(bool isComplete);

  // -------------------- 🎨 Theme --------------------

  /// Saves the current theme mode (e.g., 'light', 'dark', 'system').
  Future<void> setThemeMode(String themeMode);

  /// Retrieves the current theme mode.
  Future<String?> get themeMode;


  // -------------------- 🙍‍♂️ User Identity --------------------

  /// Saves the logged-in user's display name.
  Future<void> setDisplayName(String name);

  /// Retrieves the user's display name.
  Future<String?> get displayName;

  /// Saves the internal user name (e.g., username or employee ID).
  Future<void> setUserName(String userName);

  /// Retrieves the stored user name.
  Future<String?> get userName;

  Future<void> setUserId(String userId);

  Future<String?> get userId;

  Future<String?> get familyId;

  Future<void> setFamilyId(String familyId);

  /// Stores the current user role.
  Future<void> setUserRole(UserRole userRole);

  /// Retrieves the current user role.
  Future<UserRole> get userRole;



  /// Clears all locally stored data.
  Future<void> clearData();
}
