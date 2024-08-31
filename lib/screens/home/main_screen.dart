import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skillboost'),
      ),
      body: const Center(
        child: Text('Welcome to Skillboost!'),
      ),
    );
  }
}