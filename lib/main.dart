import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skill_boost/helpers/locator.dart';
import 'package:skill_boost/skillboost.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  runApp(
    const SkillboostApp(),
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
