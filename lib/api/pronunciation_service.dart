import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skill_boost/models/pronunciation_lesson_model.dart';
import 'package:skill_boost/utils/api_constants.dart';

class PronunciationService {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<PronunciationLesson>> getPronunciationLessons() async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl${ApiConstants.pronunciationEndpoint}'));

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