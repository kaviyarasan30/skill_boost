import 'package:skill_boost/api/pronunciation_service.dart';
import 'package:skill_boost/models/pronunciation_lesson_model.dart';

class PronunciationRepository {
  final PronunciationService _pronunciationService;

  PronunciationRepository(this._pronunciationService);

  Future<List<PronunciationLesson>> getPronunciationLessons() async {
    try {
      return await _pronunciationService.getPronunciationLessons();
    } catch (e) {
      throw Exception('Error fetching pronunciation lessons: $e');
    }
  }
}
