// vocabulary_lesson_list_page.dart
import 'package:flutter/material.dart';
import 'package:skill_boost/models/lesson_model.dart';
import 'package:skill_boost/screens/home/main_screen.dart';
import 'package:skill_boost/screens/vocabulary/VocabularyQuestionPage.dart';
import 'package:skill_boost/utils/CustomBottomNavigationBar.dart';
import 'package:skill_boost/utils/button_style.dart';
import 'package:lottie/lottie.dart';

class VocabularyLessonListPage extends StatefulWidget {
  final Lesson lesson;

  const VocabularyLessonListPage({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  @override
  _VocabularyLessonListPageState createState() =>
      _VocabularyLessonListPageState();
}

class _VocabularyLessonListPageState extends State<VocabularyLessonListPage> {
  Map<String, bool> completedQuestions = {};
  bool showSearch = false;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    int completedCount = completedQuestions.values.where((v) => v).length;
    int totalQuestions = widget.lesson.questions.length;
    double progress = totalQuestions > 0 ? completedCount / totalQuestions : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              'Vocabulary',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '${completedCount * 10} XP',
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              showSearch ? Icons.close : Icons.search,
              color: Colors.black,
            ),
            onPressed: () => setState(() => showSearch = !showSearch),
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.emoji_events_outlined, color: Colors.black),
                onPressed: () {
                  // Show achievements
                },
              ),
              if (completedCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      completedCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lesson.lessonName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.purple.withOpacity(0.2),
                      child: Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.lesson.uploader.name,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 1.0 ? Colors.green : Colors.purple,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completedCount of $totalQuestions completed',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (progress == 1.0)
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Lesson Completed!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (showSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search words',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.lesson.questions.length,
              itemBuilder: (context, index) {
                final question = widget.lesson.questions[index];
                if (searchQuery.isNotEmpty &&
                    !question.question
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase())) {
                  return SizedBox.shrink();
                }
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
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
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
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.green)
                        : Text(
                            questionNumber.toString(),
                            style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.question,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color:
                              isCompleted ? Colors.grey[600] : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Type: ${question.type}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
