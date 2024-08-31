import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skill_boost/helpers/locator.dart';
import 'skillboost.dart';
import 'firebase_options.dart';

void main() {
  runApp(const SkillboostApp());
  _initializeApp();
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await _initializeFirebase();
  setupLocator();

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  await FirebaseMessaging.instance.getInitialMessage();
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('already exists')) {
      // Firebase already initialized, no action needed
    } else {
      rethrow; // Rethrow if it's a different error
    }
  }
}
