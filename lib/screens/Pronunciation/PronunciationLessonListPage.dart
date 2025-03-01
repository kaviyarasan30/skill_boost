import 'package:flutter/material.dart';
import 'package:skill_boost/models/pronunciation_lesson_model.dart';
import 'package:skill_boost/screens/Pronunciation/PronunciationItemPage.dart';
import 'package:skill_boost/utils/CustomBottomNavigationBar.dart';

class PronunciationLessonListPage extends StatelessWidget {
  final PronunciationLesson lesson;

  const PronunciationLessonListPage({Key? key, required this.lesson})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          lesson.lessonName,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lesson Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person, size: 18, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Created by: ${lesson.uploader.name}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.signal_cellular_alt,
                          size: 18, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Difficulty: ${lesson.level}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.format_list_numbered,
                          size: 18, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        '${lesson.pronunciations.length} words',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Words to Practice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: lesson.pronunciations.length,
                itemBuilder: (context, index) {
                  final pronunciationItem = lesson.pronunciations[index];
                  return PronunciationItemCard(
                    pronunciationItem: pronunciationItem,
                    index: index,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PronunciationItemPage(
                            pronunciationItem: pronunciationItem,
                            lessonName: lesson.lessonName,
                            totalItems: lesson.pronunciations.length,
                            currentIndex: index,
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
      ),
      bottomNavigationBar: CustomBottomNavigationBar(initialIndex: 2),
    );
  }
}

class PronunciationItemCard extends StatelessWidget {
  final PronunciationItem pronunciationItem;
  final int index;
  final VoidCallback onTap;

  const PronunciationItemCard({
    Key? key,
    required this.pronunciationItem,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getTypeColor(pronunciationItem.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getTypeIcon(pronunciationItem.type),
                    color: _getTypeColor(pronunciationItem.type),
                    size: 30,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                pronunciationItem.word,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                pronunciationItem.type,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                pronunciationItem.hint,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Repeat After Me':
        return Colors.blue;
      case 'Tap & Listen':
        return Colors.green;
      case 'Phoneme Fix':
        return Colors.red;
      case 'Word Matching':
        return Colors.purple;
      case 'Slow & Fast Mode':
        return Colors.orange;
      case 'Vowel Focus':
        return Colors.teal;
      case 'Consonant Challenge':
        return Colors.indigo;
      case 'Minimal Pairs Game':
        return Colors.amber;
      case 'Rhyme Time':
        return Colors.deepOrange;
      case 'Listen & Choose':
        return Colors.brown;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Repeat After Me':
        return Icons.repeat;
      case 'Tap & Listen':
        return Icons.touch_app;
      case 'Phoneme Fix':
        return Icons.build;
      case 'Word Matching':
        return Icons.compare_arrows;
      case 'Slow & Fast Mode':
        return Icons.speed;
      case 'Vowel Focus':
        return Icons.record_voice_over;
      case 'Consonant Challenge':
        return Icons.keyboard_voice;
      case 'Minimal Pairs Game':
        return Icons.games;
      case 'Rhyme Time':
        return Icons.music_note;
      case 'Listen & Choose':
        return Icons.hearing;
      default:
        return Icons.mic;
    }
  }
}
