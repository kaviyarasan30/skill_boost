import 'package:skill_boost/api/speech_service.dart';
import 'package:skill_boost/models/speech_lesson_model.dart';

class SpeechRepository {
  final SpeechService _speechService;

  SpeechRepository(this._speechService);

  Future<List<SpeechLesson>> getSpeechLessons() async {
    try {
      return await _speechService.getSpeechLessons();
    } catch (e) {
      throw Exception('Error fetching speech lessons: $e');
    }
  }
}
