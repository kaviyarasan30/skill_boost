import 'package:flutter/material.dart';
import 'package:skill_boost/screens/home/main_screen.dart';
import 'package:skill_boost/screens/vocabulary/VocabularyQuestionPage.dart';
import 'package:skill_boost/utils/CustomBottomNavigationBar.dart';
import 'package:skill_boost/utils/button_style.dart';

class VocabularyLessonListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Vocabulary',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.account_circle, color: Colors.black, size: 30),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MainScreen()),
                  );
                },
                icon: Icon(
                  Icons.arrow_circle_left_outlined,
                  color: Colors.black,
                  size: 25,
                ),
                label: Text('Basic Words',
                    style: TextStyle(color: Colors.black, fontSize: 25)),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                LessonCard(
                  level: 'Basic Level 1',
                  completedWords: 10,
                  totalWords: 10,
                  buttonText: 'Reply',
                  isCompleted: true,
                ),
                LessonCard(
                  level: 'Basic Level 2',
                  completedWords: 5,
                  totalWords: 20,
                  buttonText: 'Continue',
                ),
                LessonCard(
                  level: 'Basic Level 2',
                  completedWords: 0,
                  totalWords: 30,
                  buttonText: 'Start',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final String level;
  final int completedWords;
  final int totalWords;
  final String buttonText;
  final bool isCompleted;

  const LessonCard({
    Key? key,
    required this.level,
    required this.completedWords,
    required this.totalWords,
    required this.buttonText,
    this.isCompleted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedWords of $totalWords words completed',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 32,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VocabularyQuestionPage()),
                    );
                  },
                  style: globalButtonStyle.copyWith(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    minimumSize: MaterialStateProperty.all(const Size(80, 32)),
                    maximumSize: MaterialStateProperty.all(const Size(80, 32)),
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  child: Text(buttonText),
                ),
              ),
              if (isCompleted)
                Positioned(
                  top: -30,
                  right: -10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
