import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skill_boost/models/lesson_model.dart';

class LessonService {
  static const String baseUrl =
      'https://c48b-2409-40f4-40c0-2e6c-a989-9319-7944-9135.ngrok-free.app/api';

  Future<List<Lesson>> getLessons() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/files'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          final lessonsData = jsonResponse['data']['lessons'] as List;
          return lessonsData.map((lesson) => Lesson.fromJson(lesson)).toList();
        }
      }
      throw Exception('Failed to load lessons');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
