import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _validUser = 'admin';
  static const String _validPassword = '12345';
  static const String _userKey = 'auth_username';

  Future<bool> login(String username, String password) async {
    if (username != _validUser || password != _validPassword) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, username);
    return true;
  }

  Future<String?> getLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
