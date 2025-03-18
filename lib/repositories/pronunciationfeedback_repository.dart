import 'dart:io';
import 'package:skill_boost/api/pronunciationfeedback_service.dart';
import 'package:skill_boost/models/pronunciationfeedback_model.dart';

class PronunciationFeedbackRepository {
  final PronunciationFeedbackService _service;

  PronunciationFeedbackRepository(this._service);

  // Submit pronunciation recordings
  Future<SubmitResponse> submitPronunciationRecordings({
    required String lessonId,
    required List<Recording> recordings,
  }) async {
    try {
      final response = await _service.submitPronunciationRecordings(
        lessonId: lessonId,
        recordings: recordings,
      );

      return SubmitResponse.fromJson(response);
    } catch (e) {
      throw Exception('Error submitting pronunciation recordings: $e');
    }
  }

  // Get all submissions for a user
  Future<SubmissionListResponse> getUserSubmissions({String? lessonId}) async {
    try {
      return await _service.getUserPronunciationSubmissions(lessonId: lessonId);
    } catch (e) {
      throw Exception('Error fetching user submissions: $e');
    }
  }

  // Get a specific submission
  Future<PronunciationFeedbackResponse> getSubmissionById(
      String submissionId) async {
    try {
      return await _service.getPronunciationSubmissionById(submissionId);
    } catch (e) {
      throw Exception('Error fetching submission: $e');
    }
  }

  // Convert audio file to base64 string
  Future<String> convertAudioToBase64(File audioFile) async {
    try {
      return await PronunciationFeedbackService.fileToBase64(audioFile);
    } catch (e) {
      throw Exception('Error converting audio to base64: $e');
    }
  }
}
