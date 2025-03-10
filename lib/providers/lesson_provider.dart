import 'package:flutter/foundation.dart';
import 'package:skill_boost/models/lesson_model.dart';
import 'package:skill_boost/repositories/lesson_repository.dart';

class LessonProvider with ChangeNotifier {
  final LessonRepository _repository;

  LessonProvider(this._repository);

  List<Lesson> _lessons = [];
  bool _isLoading = false;
  String _error = '';

  List<Lesson> get lessons => _lessons;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchLessons() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _lessons = await _repository.getLessons();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
