// Updated model classes for pronunciation feedback

class Recording {
  final String wordId;
  final String word;
  final String audioFile; // Base64 encoded audio

  Recording({
    required this.wordId,
    required this.word,
    required this.audioFile,
  });

  Map<String, dynamic> toJson() {
    return {
      'word_id': wordId,
      'word': word,
      'audio_file': audioFile,
    };
  }
}

class FeedbackRecording {
  final String wordId;
  final String word;
  final String audioUrl;
  final int accuracy;
  final String feedback;
  final String transcript;

  FeedbackRecording({
    required this.wordId,
    required this.word,
    required this.audioUrl,
    required this.accuracy,
    required this.feedback,
    required this.transcript,
  });

  factory FeedbackRecording.fromJson(Map<String, dynamic> json) {
    return FeedbackRecording(
      wordId: json['word_id'] ?? '',
      word: json['word'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      accuracy: json['accuracy'] ?? 0,
      feedback: json['feedback'] ?? 'No feedback available',
      transcript: json['transcript'] ?? '',
    );
  }
}

class PronunciationSubmission {
  final String? id;
  final String userId;
  final Map<String, dynamic>? lessonId;
  final List<FeedbackRecording>? recordings;
  final int overallAccuracy;
  final bool passed;
  final DateTime submittedAt;
  final String status;

  PronunciationSubmission({
    this.id,
    required this.userId,
    this.lessonId,
    this.recordings,
    required this.overallAccuracy,
    required this.passed,
    required this.submittedAt,
    this.status = 'completed',
  });

  factory PronunciationSubmission.fromJson(Map<String, dynamic> json) {
    return PronunciationSubmission(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      lessonId: json['lesson_id'] is Map ? json['lesson_id'] : null,
      recordings: json['recordings'] != null
          ? List<FeedbackRecording>.from(
              json['recordings'].map((x) => FeedbackRecording.fromJson(x)))
          : null,
      overallAccuracy: json['overall_accuracy'] ?? 0,
      passed: json['passed'] ?? false,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : DateTime.now(),
      status: json['status'] ?? 'completed',
    );
  }

  String get lessonName => lessonId?['lesson_name'] ?? 'Unknown Lesson';
}

class SubmitResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  SubmitResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SubmitResponse.fromJson(Map<String, dynamic> json) {
    return SubmitResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  String? get submissionId => data?['submission_id'];
  List<FeedbackRecording>? get recordings => data?['recordings'] != null
      ? List<FeedbackRecording>.from(
          data!['recordings'].map((x) => FeedbackRecording.fromJson(x)))
      : null;
  int get overallAccuracy => data?['overall_accuracy'] ?? 0;
  bool get passed => data?['passed'] ?? false;
}

class SubmissionListResponse {
  final bool success;
  final List<PronunciationSubmission> submissions;

  SubmissionListResponse({
    required this.success,
    required this.submissions,
  });

  factory SubmissionListResponse.fromJson(Map<String, dynamic> json) {
    return SubmissionListResponse(
      success: json['success'] ?? false,
      submissions: json['data'] != null
          ? List<PronunciationSubmission>.from(
              json['data'].map((x) => PronunciationSubmission.fromJson(x)))
          : [],
    );
  }
}

class PronunciationFeedbackResponse {
  final bool success;
  final String? message;
  final PronunciationSubmission? data;

  PronunciationFeedbackResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory PronunciationFeedbackResponse.fromJson(Map<String, dynamic> json) {
    return PronunciationFeedbackResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? PronunciationSubmission.fromJson(json['data'])
          : null,
    );
  }
}
