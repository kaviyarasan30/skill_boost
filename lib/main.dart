import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:skill_boost/providers/auth_providers.dart';
import 'package:skill_boost/providers/lesson_provider.dart';
import 'package:skill_boost/providers/profile_provider.dart';
import 'package:skill_boost/providers/pronunciation_provider.dart';
import 'package:skill_boost/providers/pronunciationfeedback_provider.dart';
import 'package:skill_boost/providers/speech_provider.dart';
import 'package:skill_boost/skillboost.dart';
import 'helpers/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => locator<LessonProvider>()),
        ChangeNotifierProvider(create: (_) => locator<PronunciationProvider>()),
        ChangeNotifierProvider(create: (_) => locator<SpeechProvider>()),
         ChangeNotifierProvider(create: (_) => locator<ProfileProvider>()),
         ChangeNotifierProvider(create: (_) => locator<PronunciationFeedbackProvider>())
      ],
      child: const SkillboostApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setupLocator();

  // Initialize auth state
  await locator<AuthProvider>().initAuthState();

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
}
