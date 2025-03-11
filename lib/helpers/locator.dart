import 'package:get_it/get_it.dart';
import 'package:skill_boost/api/auth_service.dart';
import 'package:skill_boost/api/lesson_service.dart';
import 'package:skill_boost/api/profile_service.dart';
import 'package:skill_boost/api/pronunciation_service.dart';
import 'package:skill_boost/api/speech_service.dart';
import 'package:skill_boost/providers/auth_providers.dart';
import 'package:skill_boost/providers/lesson_provider.dart';
import 'package:skill_boost/providers/profile_provider.dart';
import 'package:skill_boost/providers/pronunciation_provider.dart';
import 'package:skill_boost/providers/speech_provider.dart';
import 'package:skill_boost/repositories/auth_repositories.dart';
import 'package:skill_boost/repositories/lesson_repository.dart';
import 'package:skill_boost/repositories/profile_repositories.dart';
import 'package:skill_boost/repositories/pronunciation_repository.dart';
import 'package:skill_boost/repositories/speech_repository.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  // Services
  locator.registerLazySingleton(() => LessonService());
  locator.registerLazySingleton(() => PronunciationService());
  locator.registerLazySingleton(() => SpeechService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => ProfileService());

  // Repositories
  locator
      .registerLazySingleton(() => LessonRepository(locator<LessonService>()));
  locator.registerLazySingleton(
      () => PronunciationRepository(locator<PronunciationService>()));
  locator
      .registerLazySingleton(() => SpeechRepository(locator<SpeechService>()));
  locator.registerLazySingleton(() => AuthRepository(locator<AuthService>()));
  locator.registerLazySingleton(() => ProfileRepository(locator<ProfileService>()));

  // Providers

  locator
      .registerLazySingleton(() => LessonProvider(locator<LessonRepository>()));
  locator.registerLazySingleton(
      () => PronunciationProvider(locator<PronunciationRepository>()));
  locator
      .registerLazySingleton(() => SpeechProvider(locator<SpeechRepository>()));
  locator.registerLazySingleton(() => AuthProvider(locator<AuthRepository>()));
  locator.registerLazySingleton(() => ProfileProvider(locator<ProfileRepository>()));
}
