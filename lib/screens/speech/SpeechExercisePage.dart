import 'package:flutter/material.dart';
import 'package:skill_boost/models/speech_lesson_model.dart';
import 'package:skill_boost/utils/button_style.dart';

class SpeechExercisePage extends StatefulWidget {
  final Exercise exercise;
  final String lessonName;
  final int totalExercises;
  final int currentIndex;

  const SpeechExercisePage({
    Key? key,
    required this.exercise,
    required this.lessonName,
    required this.totalExercises,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _SpeechExercisePageState createState() => _SpeechExercisePageState();
}

class _SpeechExercisePageState extends State<SpeechExercisePage> {
  bool _isRecording = false;
  bool _hasRecorded = false;
  String _recordingStatus = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          widget.lessonName,
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
            // Progress indicator
            LinearProgressIndicator(
              value: (widget.currentIndex + 1) / widget.totalExercises,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 8),
            Text(
              'Exercise ${widget.currentIndex + 1} of ${widget.totalExercises}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),

            // Exercise type
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.exercise.type,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Exercise question
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.exercise.question,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  // If it's an image description exercise, show a placeholder for the image
                  if (widget.exercise.type == 'Describe the Picture')
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Image will load here',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Spacer(),

            // Recording status
            if (_recordingStatus.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    _recordingStatus,
                    style: TextStyle(
                      color: _hasRecorded ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Recording button
            Center(
              child: GestureDetector(
                onTap: _toggleRecording,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.red : Colors.blue)
                            .withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                _isRecording
                    ? 'Tap to stop recording'
                    : 'Tap to start recording',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(height: 24),

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.currentIndex > 0)
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, size: 16),
                        SizedBox(width: 8),
                        Text('Previous'),
                      ],
                    ),
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  )
                else
                  SizedBox(width: 100),
                if (widget.currentIndex < widget.totalExercises - 1)
                  ElevatedButton(
                    onPressed: _hasRecorded
                        ? () {
                            // In a real app, you would navigate to the next exercise here
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: Row(
                      children: [
                        Text('Next'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[500],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _hasRecorded
                        ? () {
                            // In a real app, you would complete the lesson here
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        : null,
                    child: Row(
                      children: [
                        Text('Complete'),
                        SizedBox(width: 8),
                        Icon(Icons.check, size: 16),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleRecording() {
    setState(() {
      if (_isRecording) {
        // Stop recording
        _isRecording = false;
        _hasRecorded = true;
        _recordingStatus = 'Recording saved! ✓';

        // In a real app, you would implement actual recording functionality here
      } else {
        // Start recording
        _isRecording = true;
        _recordingStatus = 'Recording in progress...';

        // In a real app, you would implement actual recording functionality here
      }
    });
  }
}
