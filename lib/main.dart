import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:skill_boost/providers/lesson_provider.dart';
import 'package:skill_boost/providers/pronunciation_provider.dart';
import 'package:skill_boost/providers/speech_provider.dart';

import 'package:skill_boost/skillboost.dart';

import 'helpers/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<LessonProvider>()),
        ChangeNotifierProvider(create: (_) => locator<PronunciationProvider>()),
        ChangeNotifierProvider(create: (_) => locator<SpeechProvider>()),
      ],
      child: const SkillboostApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setupLocator();

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
}
