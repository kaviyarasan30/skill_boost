import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_boost/api/pronunciation_service.dart';
import 'package:skill_boost/models/pronunciation_lesson_model.dart';
import 'package:skill_boost/providers/auth_provider.dart';
import 'package:skill_boost/screens/Pronunciation/PronunciationLessonListPage.dart';
import 'package:skill_boost/utils/CustomBottomNavigationBar.dart';
import 'package:skill_boost/utils/button_style.dart';
import 'package:skill_boost/utils/global_app_bar.dart';
import 'package:lottie/lottie.dart';

class PronunciationScreen extends StatelessWidget {
  final PronunciationService _pronunciationService = PronunciationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalAppBar(
        title: 'Pronunciation',
        achievementCount: 3,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Goal: 70%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '7/10 Lessons',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SearchBar(),
          ),
          SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<PronunciationLesson>>(
              future: _pronunciationService.getPronunciationLessons(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Lottie.network(
                      'https://assets1.lottiefiles.com/packages/lf20_qm8eqzse.json',
                      width: 200,
                      height: 200,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No pronunciation lessons available'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final lesson = snapshot.data![index];
                    return PronunciationCard(
                      lesson: lesson,
                      isLocked: index > 2,
                      progress: index == 0 ? 1.0 : (index == 1 ? 0.6 : 0.0),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(initialIndex: 2),
    );
  }
}

class PronunciationCard extends StatelessWidget {
  final PronunciationLesson lesson;
  final bool isLocked;
  final double progress;

  const PronunciationCard({
    Key? key,
    required this.lesson,
    this.isLocked = false,
    this.progress = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getLevelColor(lesson.level).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Icon(
                        _getLevelIcon(lesson.level),
                        color: _getLevelColor(lesson.level),
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.lessonName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              lesson.uploader.name,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            _buildDifficultyBadge(lesson.level),
                            SizedBox(width: 8),
                            Text(
                              '${lesson.pronunciations.length} words',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isLocked)
                    ElevatedButton(
                      style: globalButtonStyle.copyWith(
                        backgroundColor: MaterialStateProperty.all(
                          progress == 1.0 ? Colors.green : Colors.purple,
                        ),
                      ),
                      child: Text(
                        progress == 1.0 ? 'Review' : 'Start',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                PronunciationLessonListPage(lesson: lesson),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            if (progress > 0 && progress < 1.0)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  minHeight: 4,
                ),
              ),
            if (isLocked)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Complete previous lessons',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String level) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getLevelColor(level).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: _getLevelColor(level),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'basic':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'basic':
        return Icons.school_outlined;
      case 'intermediate':
        return Icons.psychology_outlined;
      case 'advanced':
        return Icons.workspace_premium_outlined;
      default:
        return Icons.book_outlined;
    }
  }
}
