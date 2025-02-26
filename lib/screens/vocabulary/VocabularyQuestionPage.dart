import 'package:flutter/material.dart';
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

class _VocabularyQuestionPageState extends State<VocabularyQuestionPage> {
  String? selectedAnswer;
  bool hasSubmitted = false;
  bool showDefinition = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Vocabulary',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Question ${widget.question.id}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.question.type),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildQuestionCard(),
                SizedBox(height: 16),
                ...widget.question.options
                    .map((option) => _buildAnswerTile(option))
                    .toList(),
                if (hasSubmitted) ...[
                  SizedBox(height: 16),
                  _buildFeedbackCard(),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasSubmitted && !showDefinition)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  setState(() {
                    showDefinition = true;
                  });
                },
                child: Text('Show Definition'),
              ),
            ),
          if (!hasSubmitted)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: selectedAnswer == null ? null : _submitAnswer,
                child: Text('Submit Answer'),
              ),
            ),
          if (showDefinition)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  widget.onComplete();
                  Navigator.of(context).pop();
                },
                child: Text('Continue'),
              ),
            ),
          CustomBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question.type,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            widget.question.question,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (widget.question.type == "MCQ" ||
              widget.question.type == "Vocabulary Identification")
            Text(
              'Choose the best answer',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          if (widget.question.type == "Fill in the blanks" ||
              widget.question.type == "Sentence Completion")
            Text(
              'Select the correct word to complete the sentence',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerTile(String answer) {
    bool isSelected = selectedAnswer == answer;
    bool isCorrect = widget.question.correctAnswer == answer;
    Color? backgroundColor;

    if (hasSubmitted) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withOpacity(0.1);
      }
    } else if (isSelected) {
      backgroundColor = Colors.grey.withOpacity(0.1);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasSubmitted && isCorrect
              ? Colors.green
              : hasSubmitted && isSelected && !isCorrect
                  ? Colors.red
                  : isSelected
                      ? Colors.black
                      : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
        color: backgroundColor,
      ),
      child: ListTile(
        title: Text(
          answer,
          style: TextStyle(
            color: hasSubmitted && isCorrect
                ? Colors.green
                : hasSubmitted && isSelected && !isCorrect
                    ? Colors.red
                    : Colors.black,
          ),
        ),
        trailing: hasSubmitted
            ? Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              )
            : null,
        onTap: hasSubmitted
            ? null
            : () {
                setState(() {
                  selectedAnswer = answer;
                });
              },
      ),
    );
  }

  Widget _buildFeedbackCard() {
    bool isCorrect = selectedAnswer == widget.question.correctAnswer;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCorrect ? 'Correct!' : 'Incorrect',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
          if (showDefinition) ...[
            SizedBox(height: 8),
            Text(
              'Definition:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              widget.question.definition,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }

  void _submitAnswer() {
    setState(() {
      hasSubmitted = true;
    });
  }
}
