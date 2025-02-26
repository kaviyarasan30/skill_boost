import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skill_boost/models/pronunciation_lesson_model.dart';

class PronunciationService {
  static const String baseUrl =
      'https://8fbb-2409-40f4-301f-25f0-c1d9-6b90-f4ac-6e0e.ngrok-free.app/api';

  Future<List<PronunciationLesson>> getPronunciationLessons() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pronunciation'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          final lessonsData = jsonResponse['data']['lessons'] as List;
          return lessonsData
              .map((lesson) => PronunciationLesson.fromJson(lesson))
              .toList();
        }
      }
      throw Exception('Failed to load pronunciation lessons');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
