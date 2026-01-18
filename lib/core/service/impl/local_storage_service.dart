import 'package:shared_preferences/shared_preferences.dart';
import '../../enums/user_role.dart';
import '../i_local_storage_service.dart';

/// A concrete implementation of [ILocalStorageService] using SharedPreferences.
///
/// Stores user session data such as tokens, role, and zone info locally.
final class LocalStorageService implements ILocalStorageService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userNameKey = 'user_name';
  static const _userRoleKey = 'user_role';
  static const _userIdKey = 'user_id';
  static const _familyIdKey = 'family_id';
  static const _displayNameKey = 'display_name';
  static const _isOnBoardingComplete = 'is_onboarding_complete';


  SharedPreferences? _cachedPrefs;

  Future<SharedPreferences> get _prefs async =>
      _cachedPrefs ??= await SharedPreferences.getInstance();

  // -------------------- 🔐 Authentication --------------------

  @override
  Future<void> setAccessToken(String accessToken) async {
    final prefs = await _prefs;
    await prefs.setString(_accessTokenKey, accessToken);
  }

  @override
  Future<String?> get accessToken async {
    final prefs = await _prefs;
    return prefs.getString(_accessTokenKey);
  }

  @override
  Future<void> setRefreshToken(String refreshToken) async {
    final prefs = await _prefs;
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  @override
  Future<String?> get refreshToken async {
    final prefs = await _prefs;
    return prefs.getString(_refreshTokenKey);
  }

  // -------------------- 🙍‍♂️ User Info --------------------

  @override
  Future<void> setUserName(String userName) async {
    final prefs = await _prefs;
    await prefs.setString(_userNameKey, userName);
  }

  @override
  Future<String?> get userName async {
    final prefs = await _prefs;
    return prefs.getString(_userNameKey);
  }

  @override
  Future<void> setDisplayName(String displayName) async {
    final prefs = await _prefs;
    await prefs.setString(_displayNameKey, displayName);
  }

  @override
  Future<String?> get displayName async {
    final prefs = await _prefs;
    return prefs.getString(_displayNameKey);
  }

  @override
  Future<void> setUserRole(UserRole userRole) async {
    final prefs = await _prefs;
    await prefs.setString(_userRoleKey, userRole.name);
  }

  @override
  Future<UserRole> get userRole async {
    final roleName = (await _prefs).getString(_userRoleKey);
    return UserRole.values.firstWhere(
      (e) => e.name == roleName,
      orElse: () => UserRole.unknown,
    );
  }

  @override
  Future<void> setUserId(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(_userIdKey, userId);
  }

  @override
  Future<String?> get userId async {
    final prefs = await _prefs;
    return prefs.getString(_userIdKey);
  }

  @override
  Future<void> setFamilyId(String familyId) async {
    final prefs = await _prefs;
    await prefs.setString(_familyIdKey, familyId);
  }

  @override
  Future<String?> get familyId async {
    final prefs = await _prefs;
    return prefs.getString(_familyIdKey);
  }

  // -------------------- 🧹 Full Session Cleanup --------------------

  @override
  Future<void> clearData() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  @override
  Future<bool?> get isOnBoardingComplete async {
    final prefs = await _prefs;
    return prefs.getBool(_isOnBoardingComplete) ?? false;
  }

  @override
  Future<void> setOnBoardingComplete(bool isComplete) async {
    final prefs = await _prefs;
    prefs.setBool(_isOnBoardingComplete, isComplete);
  }
}
