import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:skill_boost/models/lesson_model.dart';
import 'package:skill_boost/utils/CustomBottomNavigationBar.dart';

class VocabularyQuestionPage extends StatefulWidget {
  final Question question;
  final VoidCallback onComplete;

  const VocabularyQuestionPage({
    Key? key,
    required this.question,
    required this.onComplete,
  }) : super(key: key);

  @override
  _VocabularyQuestionPageState createState() => _VocabularyQuestionPageState();
}

class _VocabularyQuestionPageState extends State<VocabularyQuestionPage>
    with SingleTickerProviderStateMixin {
  String? selectedAnswer;
  bool hasSubmitted = false;
  bool showDefinition = false;
  late AnimationController _confettiController;
  int points = 0;
  int streak = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleAnswer(String answer) {
    if (hasSubmitted) return;

    setState(() {
      selectedAnswer = answer;
      hasSubmitted = true;

      if (answer == widget.question.correctAnswer) {
        streak++;
        points += (10 * streak); // Bonus points for streaks
        _confettiController.forward();
      } else {
        streak = 0;
      }
    });

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Vocabulary',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                    '$points XP',
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
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department,
                    color: Colors.purple, size: 16),
                SizedBox(width: 4),
                Text(
                  '$streak 🔥',
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          widget.question.question,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (showDefinition) ...[
                          SizedBox(height: 16),
                          Text(
                            widget.question.definition ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ...widget.question.options.map((option) {
                  final bool isSelected = selectedAnswer == option;
                  final bool isCorrect =
                      widget.question.correctAnswer == option;
                  final Color cardColor = hasSubmitted
                      ? (isCorrect
                          ? Colors.green.withOpacity(0.2)
                          : (isSelected
                              ? Colors.red.withOpacity(0.2)
                              : Colors.white))
                      : (isSelected
                          ? Colors.purple.withOpacity(0.2)
                          : Colors.white);

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      child: Card(
                        elevation: isSelected ? 4 : 2,
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: isSelected
                                ? (hasSubmitted
                                    ? (isCorrect ? Colors.green : Colors.red)
                                    : Colors.purple)
                                : Colors.grey.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _handleAnswer(option),
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? (hasSubmitted
                                              ? (isCorrect
                                                  ? Colors.green[700]
                                                  : Colors.red[700])
                                              : Colors.purple[700])
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (hasSubmitted && (isCorrect || isSelected))
                                  Icon(
                                    isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                Spacer(),
                if (!showDefinition)
                  TextButton(
                    onPressed: () => setState(() => showDefinition = true),
                    child: Text(
                      'Show Definition',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (hasSubmitted && selectedAnswer == widget.question.correctAnswer)
            Positioned.fill(
              child: IgnorePointer(
                child: Lottie.network(
                  'https://assets9.lottiefiles.com/packages/lf20_touohxv0.json',
                  controller: _confettiController,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
