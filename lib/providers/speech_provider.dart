import 'package:flutter/foundation.dart';
import 'package:skill_boost/models/speech_lesson_model.dart';
import 'package:skill_boost/repositories/speech_repository.dart';

class SpeechProvider with ChangeNotifier {
  final SpeechRepository _repository;

  SpeechProvider(this._repository);

  List<SpeechLesson> _lessons = [];
  bool _isLoading = false;
  String _error = '';

  List<SpeechLesson> get lessons => _lessons;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchSpeechLessons() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _lessons = await _repository.getSpeechLessons();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
