import 'package:skill_boost/models/lesson_model.dart';

class PronunciationItem {
  final String id;
  final String word;
  final String type;
  final String hint;
  final String audioFile;

  PronunciationItem({
    required this.id,
    required this.word,
    required this.type,
    required this.hint,
    required this.audioFile,
  });

  factory PronunciationItem.fromJson(Map<String, dynamic> json) {
    return PronunciationItem(
      id: json['_id'],
      word: json['word'],
      type: json['type'],
      hint: json['hint'],
      audioFile: json['audio_file'],
    );
  }
}

class PronunciationLesson {
  final String id;
  final Uploader uploader;
  final String lessonType;
  final String lessonName;
  final String level;
  final List<PronunciationItem> pronunciations;
  final String excelFileUrl;
  final String audioZipUrl;
  final DateTime uploadedAt;

  PronunciationLesson({
    required this.id,
    required this.uploader,
    required this.lessonType,
    required this.lessonName,
    required this.level,
    required this.pronunciations,
    required this.excelFileUrl,
    required this.audioZipUrl,
    required this.uploadedAt,
  });

  factory PronunciationLesson.fromJson(Map<String, dynamic> json) {
    return PronunciationLesson(
      id: json['_id'],
      uploader: Uploader.fromJson(json['uploader_id']),
      lessonType: json['lesson_type'],
      lessonName: json['lesson_name'],
      level: json['level'],
      pronunciations: List<PronunciationItem>.from(
          json['pronunciations'].map((x) => PronunciationItem.fromJson(x))),
      excelFileUrl: json['excel_file_url'],
      audioZipUrl: json['audio_zip_url'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }
}
