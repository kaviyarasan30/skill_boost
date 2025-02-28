import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skill_boost/models/speech_lesson_model.dart';

class SpeechService {
  static const String baseUrl =
      'https://43d4-2409-40f4-3015-31ca-555-efb6-1326-a105.ngrok-free.app/api';

  Future<List<SpeechLesson>> getSpeechLessons() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/speech'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          final lessonsData = jsonResponse['data']['lessons'] as List;
          return lessonsData
              .map((lesson) => SpeechLesson.fromJson(lesson))
              .toList();
        }
      }
      throw Exception('Failed to load speech lessons');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
