import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skill_boost/models/lesson_model.dart';
import 'package:skill_boost/utils/api_constants.dart';

class LessonService {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<Lesson>> getLessons() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl${ApiConstants.lessonsEndpoint}'));

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
