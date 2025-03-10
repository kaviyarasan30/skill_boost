import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_boost/models/speech_lesson_model.dart';
import 'package:skill_boost/providers/speech_provider.dart';
import 'package:skill_boost/screens/speech/SpeechLessonListPage.dart';
import 'package:skill_boost/utils/CustomBottomNavigationBar.dart';
import 'package:skill_boost/utils/button_style.dart';
import 'package:skill_boost/utils/global_app_bar.dart';
import 'package:lottie/lottie.dart';

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SpeechProvider>(context, listen: false).fetchSpeechLessons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalAppBar(
        title: 'Speech',
        achievementCount: 2,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: 0.5,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Goal: 50%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '5/10 Exercises',
                      style: TextStyle(
                        color: Colors.blue,
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
            child: Consumer<SpeechProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: Lottie.network(
                      'https://assets3.lottiefiles.com/packages/lf20_szviypry.json',
                      width: 200,
                      height: 200,
                    ),
                  );
                } else if (provider.error.isNotEmpty) {
                  return Center(child: Text('Error: ${provider.error}'));
                } else if (provider.lessons.isEmpty) {
                  return Center(child: Text('No speech lessons available'));
                }

                return ListView.builder(
                  itemCount: provider.lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = provider.lessons[index];
                    return SpeechCard(
                      lesson: lesson,
                      isLocked: index > 2,
                      progress: index == 0 ? 1.0 : (index == 1 ? 0.3 : 0.0),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(initialIndex: 1),
    );
  }
}

class SpeechCard extends StatelessWidget {
  final SpeechLesson lesson;
  final bool isLocked;
  final double progress;

  const SpeechCard({
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
                              '${lesson.exercises.length} exercises',
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
                          progress == 1.0 ? Colors.green : Colors.blue,
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
                                SpeechLessonListPage(lesson: lesson),
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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
        return Icons.record_voice_over;
      case 'intermediate':
        return Icons.mic;
      case 'advanced':
        return Icons.campaign;
      default:
        return Icons.speaker;
    }
  }
}
