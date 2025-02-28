import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skill_boost/models/lesson_model.dart';

class LessonService {
  static const String baseUrl =
      'https://43d4-2409-40f4-3015-31ca-555-efb6-1326-a105.ngrok-free.app/api';

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
