import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_boost/models/pronunciationfeedback_model.dart';
import 'package:skill_boost/utils/api_constants.dart';

class PronunciationFeedbackService {
  String _token;
  final http.Client client;

  PronunciationFeedbackService({required String token, required this.client})
      : _token = token;

  // Update token method
  Future<void> updateToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
  }

  // Get current token
  String get token => _token;

  // Submit pronunciation recordings
  Future<Map<String, dynamic>> submitPronunciationRecordings({
    required String lessonId,
    required List<Recording> recordings,
  }) async {
    try {
      // Update token before making request
      await updateToken();

      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.pronunciationEndpoint}/submit');

      // Convert recordings to the expected format
      final List<Map<String, dynamic>> recordingsData =
          recordings.map((recording) => recording.toJson()).toList();

      final requestBody = {
        'lesson_id': lessonId,
        'recordings': recordingsData,
      };

      // Debug print request size
      final requestSize = jsonEncode(requestBody).length;
      print('Debug: Request body size: ${requestSize / 1024 / 1024}MB');

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit recordings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting pronunciation recordings: $e');
    }
  }

  // Get all user's pronunciation submissions
  Future<SubmissionListResponse> getUserPronunciationSubmissions(
      {String? lessonId}) async {
    try {
      // Update token before making request
      await updateToken();

      String url =
          '${ApiConstants.baseUrl}${ApiConstants.pronunciationEndpoint}/submissions';

      if (lessonId != null) {
        url += '?lesson_id=$lessonId';
      }

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        return SubmissionListResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get submissions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching pronunciation submissions: $e');
    }
  }

  // Get a specific submission by ID
  Future<PronunciationFeedbackResponse> getPronunciationSubmissionById(
      String submissionId) async {
    try {
      // Update token before making request
      await updateToken();

      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.pronunciationEndpoint}/submission/$submissionId');

      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        return PronunciationFeedbackResponse.fromJson(
            jsonDecode(response.body));
      } else {
        throw Exception('Failed to get submission: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching pronunciation submission: $e');
    }
  }

  // Helper method to convert audio file to base64
  static Future<String> fileToBase64(File file) async {
    try {
      // Read the file bytes
      final bytes = await file.readAsBytes();

      // If file is larger than 5MB, compress it
      if (bytes.length > 5 * 1024 * 1024) {
        // TODO: Implement audio compression if needed
        // For now, we'll just use the original file
      }

      return 'data:audio/mp3;base64,${base64Encode(bytes)}';
    } catch (e) {
      throw Exception('Error converting audio to base64: $e');
    }
  }
}
