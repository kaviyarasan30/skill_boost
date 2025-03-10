import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_boost/api/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  // For storing and retrieving the auth token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Auth methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await _authService.login(email, password);

      if (result['success'] && result['token'] != null) {
        await saveToken(result['token']);
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'error': 'Error logging in: $e',
      };
    }
  }

  Future<Map<String, dynamic>> register(String userName, String email,
      String password, String confirmPassword) async {
    try {
      final result = await _authService.register(
          userName, email, password, confirmPassword);

      if (result['success'] && result['token'] != null) {
        await saveToken(result['token']);
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'error': 'Error registering: $e',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      return await _authService.resetPassword(email);
    } catch (e) {
      return {
        'success': false,
        'error': 'Error resetting password: $e',
      };
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await clearToken();
  }
}
