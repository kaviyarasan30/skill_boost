import 'package:skill_boost/models/lesson_model.dart';

class Exercise {
  final String id;
  final String type;
  final String question;

  Exercise({
    required this.id,
    required this.type,
    required this.question,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['question_id'],
      type: json['type'],
      question: json['question'],
    );
  }
}

class SpeechLesson {
  final String id;
  final Uploader uploader;
  final String lessonType;
  final String lessonName;
  final String level;
  final List<Exercise> exercises;
  final String fileUrl;
  final DateTime uploadedAt;

  SpeechLesson({
    required this.id,
    required this.uploader,
    required this.lessonType,
    required this.lessonName,
    required this.level,
    required this.exercises,
    required this.fileUrl,
    required this.uploadedAt,
  });

  factory SpeechLesson.fromJson(Map<String, dynamic> json) {
    return SpeechLesson(
      id: json['_id'],
      uploader: Uploader.fromJson(json['uploader_id']),
      lessonType: json['lesson_type'],
      lessonName: json['lesson_name'],
      level: json['level'],
      exercises: List<Exercise>.from(
          json['exercises'].map((x) => Exercise.fromJson(x))),
      fileUrl: json['file_url'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }
}
