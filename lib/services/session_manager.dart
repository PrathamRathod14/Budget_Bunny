import 'package:budget_buddy/utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setFirstTime(bool value) async {
    await _prefs?.setBool(AppConstants.isFirstTimeKey, value);
  }

  Future<bool> isFirstTime() async {
    return _prefs?.getBool(AppConstants.isFirstTimeKey) ?? true;
  }

  Future<void> setAuthToken(String token) async {
    await _secureStorage.write(key: AppConstants.authTokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConstants.authTokenKey);
  }

  Future<void> setUserId(String userId) async {
    await _secureStorage.write(key: AppConstants.userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: AppConstants.userIdKey);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: AppConstants.authTokenKey);
    await _secureStorage.delete(key: AppConstants.userIdKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null;
  }
}