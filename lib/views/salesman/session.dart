import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _isLoggedInKey = "IS_LOGGED_IN";
  static const String _userIdKey = "USER_ID";
  static const String _namedKey = "name";
  static const String _addressKey = "address";
  static const String _birthdayKey = "birthday";
  static const String _passwordKey = "password";
  static const String _phoneKey = "phone";
  static const String _roleKey = "role";
  static const String _imageKey = "imageProfile";

  Future<void> saveUserSession(
      String userId,
      String name,
      String address,
      String birthday,
      String image,
      String role,
      String password,
      String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_namedKey, name);
    await prefs.setString(_addressKey, address);
    await prefs.setString(_birthdayKey, birthday);
    await prefs.setString(_passwordKey, password);
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_roleKey, role);
    await prefs.setString(_imageKey, image);
  }

  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userIdKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }
}
