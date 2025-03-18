class ApiConstants {
  static const String baseUrl =
      'https://4124-2409-40f4-4111-54db-7d4c-706f-2da1-bf9e.ngrok-free.app/api';

  // Endpoints
  static const String lessonsEndpoint = '/files';
  static const String pronunciationEndpoint = '/pronunciation';
  static const String pronunciationFeedbackEndpoint = '/pronunciation-feedback';
  static const String speechEndpoint = '/speech';
  static const String signupEndpoint = '/user/signup';
  static const String loginEndpoint = '/user/signin';
  static const String userDetailsEndpoint = '/user/details';
  static const String resetPasswordEndpoint = '/user/password-reset';
  static const String submitPronunciationEndpoint =
      '/pronunciation-feedback/submit';
  static const String getFeedbackEndpoint = '/pronunciation-feedback/feedback';
  static const String getUserFeedbackEndpoint = '/pronunciation-feedback/user';
  static const String getLessonFeedbackEndpoint =
      '/pronunciation-feedback/lesson';
}
