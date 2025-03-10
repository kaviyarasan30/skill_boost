import 'package:flutter/foundation.dart';
import 'package:skill_boost/models/pronunciation_lesson_model.dart';
import 'package:skill_boost/repositories/pronunciation_repository.dart';

class PronunciationProvider with ChangeNotifier {
  final PronunciationRepository _repository;

  PronunciationProvider(this._repository);

  List<PronunciationLesson> _lessons = [];
  bool _isLoading = false;
  String _error = '';

  List<PronunciationLesson> get lessons => _lessons;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchPronunciationLessons() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _lessons = await _repository.getPronunciationLessons();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
