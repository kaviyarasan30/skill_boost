import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:skill_boost/models/pronunciationfeedback_model.dart';
import 'package:skill_boost/repositories/pronunciationfeedback_repository.dart';

class PronunciationFeedbackProvider with ChangeNotifier {
  final PronunciationFeedbackRepository _repository;

  PronunciationFeedbackProvider(this._repository);

  // State variables
  bool _isSubmitting = false;
  bool _isLoading = false;
  String _error = '';
  SubmitResponse? _submitResponse;
  PronunciationSubmission? _currentSubmission;
  List<PronunciationSubmission> _userSubmissions = [];

  // Getters
  bool get isSubmitting => _isSubmitting;
  bool get isLoading => _isLoading;
  String get error => _error;
  SubmitResponse? get submitResponse => _submitResponse;
  PronunciationSubmission? get currentSubmission => _currentSubmission;
  List<PronunciationSubmission> get userSubmissions => _userSubmissions;
  String? get submissionId => _submitResponse?.submissionId;

  // Submit pronunciation recordings
  Future<bool> submitPronunciationRecordings({
    required String lessonId,
    required List<File> audioFiles,
    required List<String> wordIds,
    required List<String> words,
  }) async {
    _isSubmitting = true;
    _error = '';
    notifyListeners();

    try {
      // Convert audio files to base64 and create recordings
      final recordings = <Recording>[];

      for (int i = 0; i < audioFiles.length; i++) {
        // Check file size before processing
        final fileSize = await audioFiles[i].length();
        if (fileSize > 10 * 1024 * 1024) {
          // 10MB limit
          throw Exception(
              'Audio file ${i + 1} is too large (${fileSize / 1024 / 1024}MB). Maximum size is 10MB.');
        }

        final base64Audio =
            await _repository.convertAudioToBase64(audioFiles[i]);
        recordings.add(Recording(
          wordId: wordIds[i],
          word: words[i],
          audioFile: base64Audio,
        ));
      }

      // Submit recordings
      final response = await _repository.submitPronunciationRecordings(
        lessonId: lessonId,
        recordings: recordings,
      );

      _submitResponse = response;
      _isSubmitting = false;
      notifyListeners();
      return response.success;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // Get user's pronunciation submissions
  Future<bool> getUserSubmissions({String? lessonId}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _repository.getUserSubmissions(lessonId: lessonId);

      if (response.success) {
        _userSubmissions = response.submissions;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to get user submissions';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get a specific submission
  Future<bool> getSubmissionById(String submissionId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _repository.getSubmissionById(submissionId);

      if (response.success && response.data != null) {
        _currentSubmission = response.data;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to get submission';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear current data
  void clearSubmissionData() {
    _submitResponse = null;
    _currentSubmission = null;
    notifyListeners();
  }
}
