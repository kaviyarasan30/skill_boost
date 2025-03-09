import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skill_boost/models/speech_lesson_model.dart';

class SpeechService {
  static const String baseUrl =
      'https://c48b-2409-40f4-40c0-2e6c-a989-9319-7944-9135.ngrok-free.app/api';

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
