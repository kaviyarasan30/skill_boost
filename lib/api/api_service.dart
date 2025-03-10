import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skill_boost/utils/api_constants.dart';


class ApiService {
  final String baseUrl = ApiConstants.baseUrl;

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          return jsonResponse;
        }
      }
      throw Exception('Failed to load data from $endpoint');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Add other HTTP methods as needed (post, put, delete, etc.)
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          return jsonResponse;
        }
      }
      throw Exception('Failed to post data to $endpoint');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}