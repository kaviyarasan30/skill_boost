// vocabulary_lesson_list_page.dart
import 'package:flutter/material.dart';
import 'package:skill_boost/models/lesson_model.dart';
import 'package:skill_boost/screens/home/main_screen.dart';
import 'package:skill_boost/screens/vocabulary/VocabularyQuestionPage.dart';
import 'package:skill_boost/utils/CustomBottomNavigationBar.dart';
import 'package:skill_boost/utils/button_style.dart';

class VocabularyLessonListPage extends StatefulWidget {
  final Lesson lesson;

  const VocabularyLessonListPage({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  @override
  _VocabularyLessonListPageState createState() => _VocabularyLessonListPageState();
}

class _VocabularyLessonListPageState extends State<VocabularyLessonListPage> {
  // Track completed questions
  Map<String, bool> completedQuestions = {};

  @override
  Widget build(BuildContext context) {
    // Calculate progress
    int completedCount = completedQuestions.values.where((v) => v).length;
    int totalQuestions = widget.lesson.questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Vocabulary',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
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
                hintText: 'Search questions',
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
            child: Row(
              children: [
                TextButton.icon(
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
                  label: Text(
                    widget.lesson.lessonName,
                    style: TextStyle(color: Colors.black, fontSize: 25),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.person, size: 16),
                SizedBox(width: 4),
                Text(
                  'Created by ${widget.lesson.uploader.name}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.lesson.questions.length,
              itemBuilder: (context, index) {
                final question = widget.lesson.questions[index];
                final isCompleted = completedQuestions[question.id] ?? false;
                
                return QuestionCard(
                  questionNumber: index + 1,
                  question: question,
                  isCompleted: isCompleted,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VocabularyQuestionPage(
                          question: question,
                          onComplete: () {
                            setState(() {
                              completedQuestions[question.id] = true;
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: totalQuestions > 0 ? completedCount / totalQuestions : 0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
                SizedBox(height: 8),
                Text(
                  '$completedCount of $totalQuestions questions completed',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final int questionNumber;
  final Question question;
  final bool isCompleted;
  final VoidCallback onPressed;

  const QuestionCard({
    Key? key,
    required this.questionNumber,
    required this.question,
    required this.isCompleted,
    required this.onPressed,
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
                  'Question ${questionNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Type: ${question.type}',
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
                  onPressed: onPressed,
                  style: globalButtonStyle.copyWith(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    minimumSize: MaterialStateProperty.all(const Size(80, 32)),
                    maximumSize: MaterialStateProperty.all(const Size(80, 32)),
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  child: Text(isCompleted ? 'Review' : 'Start'),
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