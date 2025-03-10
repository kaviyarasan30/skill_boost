import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skill_boost/utils/api_constants.dart';

class AuthService {
  final String baseUrl = ApiConstants.baseUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'] ?? {},
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> register(String userName, String email,
      String password, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.signupEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_name': userName,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'] ?? {},
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset email sent',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to send password reset email',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}
