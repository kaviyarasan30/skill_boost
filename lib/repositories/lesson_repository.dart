import 'package:skill_boost/api/lesson_service.dart';
import 'package:skill_boost/models/lesson_model.dart';

class LessonRepository {
  final LessonService _lessonService;

  LessonRepository(this._lessonService);

  Future<List<Lesson>> getLessons() async {
    try {
      return await _lessonService.getLessons();
    } catch (e) {
      throw Exception('Error fetching lessons: $e');
    }
  }
}
