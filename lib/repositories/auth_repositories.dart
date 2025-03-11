import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_boost/api/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  
  AuthRepository(this._authService);
  
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _authService.login(email, password);
    if (result['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);
      if (result['user'] != null && result['user']['user_id'] != null) {
        await prefs.setString('userId', result['user']['user_id']);
      }
    }
    return result;
  }
  
  Future<Map<String, dynamic>> register(String userName, String email,
      String password, String confirmPassword) async {
    final result = await _authService.register(userName, email, password, confirmPassword);
    if (result['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);
      if (result['user'] != null && result['user']['user_id'] != null) {
        await prefs.setString('userId', result['user']['user_id']);
      }
    }
    return result;
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
  }
}