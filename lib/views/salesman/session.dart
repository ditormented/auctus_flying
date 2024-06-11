import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _userTokenKey = "USER_TOKEN";
  static const String _userIdKey = "USER_ID";

  Future<void> saveUserSession(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userTokenKey, token);
  }

  Future<Map<String, String?>> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    final token = prefs.getString(_userTokenKey);
    return {
      "userId": userId,
      "token": token,
    };
  }

  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userTokenKey);
  }
}
