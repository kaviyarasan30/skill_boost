import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skill_boost/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final String baseUrl = ApiConstants.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userId');
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'Authentication token not found',
        };
      }

      print('Fetching user details for userId: $userId with token: $token');

      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.userDetailsEndpoint}/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);

        return {
          'success': true,
          'user': data['user'] ?? {},
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ??
              'Failed to fetch user details: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Network error when fetching user details: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}
