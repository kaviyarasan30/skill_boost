import 'package:flutter/material.dart';
import 'package:skill_boost/models/pronunciation_lesson_model.dart';
import 'package:skill_boost/screens/Pronunciation/PronunciationItemPage.dart';
import 'package:skill_boost/utils/CustomBottomNavigationBar.dart';

class PronunciationLessonListPage extends StatefulWidget {
  final PronunciationLesson lesson;

  const PronunciationLessonListPage({Key? key, required this.lesson})
      : super(key: key);

  @override
  _PronunciationLessonListPageState createState() =>
      _PronunciationLessonListPageState();
}

class _PronunciationLessonListPageState
    extends State<PronunciationLessonListPage> {
  Map<int, RecordingData> _allRecordings = {};

  void _navigateToExercise(BuildContext context, int index) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => PronunciationItemPage(
          pronunciationItem: widget.lesson.pronunciations[index],
          lessonName: widget.lesson.lessonName,
          totalItems: widget.lesson.pronunciations.length,
          currentIndex: index,
          lessonId: widget.lesson.id ?? 'unknown',
          previousRecordings: _allRecordings,
        ),
      ),
    )
        .then((value) {
      if (value != null) {
        if (value is Map<String, dynamic>) {
          if (value.containsKey('recordings')) {
            setState(() {
              _allRecordings =
                  Map<int, RecordingData>.from(value['recordings']);
            });
          }
          if (value.containsKey('nextIndex')) {
            _navigateToExercise(context, value['nextIndex']);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.lesson.lessonName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: widget.lesson.pronunciations.length,
                itemBuilder: (context, index) {
                  final pronunciationItem = widget.lesson.pronunciations[index];
                  final isCompleted = _allRecordings.containsKey(index);
                  return PronunciationItemCard(
                    pronunciationItem: pronunciationItem,
                    index: index,
                    onTap: () => _navigateToExercise(context, index),
                    isCompleted: isCompleted,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(initialIndex: 2),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Practice Session',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.lesson.pronunciations.length} exercises to complete',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: Colors.purple[700],
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '15 min',
                      style: TextStyle(
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildStatItem(
                    'Exercises',
                    '${widget.lesson.pronunciations.length}',
                    Icons.format_list_numbered),
                _buildDivider(),
                _buildStatItem('Completed', '0', Icons.check_circle_outline),
                _buildDivider(),
                _buildStatItem('Accuracy', '0%', Icons.analytics_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.purple[700], size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[200],
    );
  }
}

class PronunciationItemCard extends StatelessWidget {
  final PronunciationItem pronunciationItem;
  final int index;
  final VoidCallback onTap;
  final bool isCompleted;

  const PronunciationItemCard({
    Key? key,
    required this.pronunciationItem,
    required this.index,
    required this.onTap,
    this.isCompleted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border:
                isCompleted ? Border.all(color: Colors.green, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getTypeColor(pronunciationItem.type)
                              .withOpacity(0.2),
                          _getTypeColor(pronunciationItem.type)
                              .withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getTypeColor(pronunciationItem.type)
                              .withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getTypeIcon(pronunciationItem.type),
                      color: _getTypeColor(pronunciationItem.type),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTypeColor(pronunciationItem.type)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pronunciationItem.type,
                      style: TextStyle(
                        color: _getTypeColor(pronunciationItem.type),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      pronunciationItem.hint,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (isCompleted)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
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
