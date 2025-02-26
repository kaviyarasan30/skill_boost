class Uploader {
  final String id;
  final String name;
  final String email;

  Uploader({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Uploader.fromJson(Map<String, dynamic> json) {
    return Uploader(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class Question {
  final String id;
  final String type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String definition;

  Question({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.definition,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['question_id'],
      type: json['type'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      definition: json['Definition'],
    );
  }
}

class Lesson {
  final String id;
  final Uploader uploader;
  final String lessonType;
  final String lessonName;
  final String level;
  final List<Question> questions;
  final String fileUrl;
  final DateTime uploadedAt;

  Lesson({
    required this.id,
    required this.uploader,
    required this.lessonType,
    required this.lessonName,
    required this.level,
    required this.questions,
    required this.fileUrl,
    required this.uploadedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['_id'],
      uploader: Uploader.fromJson(json['uploader_id']),
      lessonType: json['lesson_type'],
      lessonName: json['lesson_name'],
      level: json['level'],
      questions:
          List<Question>.from(json['txts'].map((x) => Question.fromJson(x))),
      fileUrl: json['file_url'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }
}
