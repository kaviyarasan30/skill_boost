import 'package:flutter/material.dart';
import 'package:skill_boost/models/pronunciation_lesson_model.dart';
import 'package:skill_boost/utils/button_style.dart';

class PronunciationItemPage extends StatefulWidget {
  final PronunciationItem pronunciationItem;
  final String lessonName;
  final int totalItems;
  final int currentIndex;

  const PronunciationItemPage({
    Key? key,
    required this.pronunciationItem,
    required this.lessonName,
    required this.totalItems,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _PronunciationItemPageState createState() => _PronunciationItemPageState();
}

class _PronunciationItemPageState extends State<PronunciationItemPage> {
  bool _isPlaying = false;
  bool _hasRecorded = false;
  bool _isRecording = false;
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (widget.currentIndex + 1) / widget.totalItems,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            SizedBox(height: 8),
            Text(
              'Word ${widget.currentIndex + 1} of ${widget.totalItems}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 30),

            // Exercise type
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getTypeColor(widget.pronunciationItem.type)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.pronunciationItem.type,
                style: TextStyle(
                  color: _getTypeColor(widget.pronunciationItem.type),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),

            // Word to pronounce
            Center(
              child: Text(
                widget.pronunciationItem.word,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Hint
            Center(
              child: Text(
                widget.pronunciationItem.hint,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: 40),

            // Audio controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Listen button
                GestureDetector(
                  onTap: _toggleAudio,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.volume_up,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 40),

                // Record button
                GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? Colors.red : Colors.green)
                              .withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Listen',
                  style: TextStyle(color: Colors.blue),
                ),
                SizedBox(width: 90),
                Text(
                  _isRecording ? 'Stop' : 'Record',
                  style: TextStyle(
                      color: _isRecording ? Colors.red : Colors.green),
                ),
              ],
            ),

            // Recording status
            if (_recordingStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Center(
                  child: Text(
                    _recordingStatus,
                    style: TextStyle(
                      color: _hasRecorded ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            Spacer(),

            // Instructions based on type
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getInstructions(widget.pronunciationItem.type),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

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
                if (widget.currentIndex < widget.totalItems - 1)
                  ElevatedButton(
                    onPressed: _hasRecorded
                        ? () {
                            // In a real app, you would navigate to the next word here
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
                      backgroundColor: Colors.purple,
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

  String _getInstructions(String type) {
    switch (type) {
      case 'Repeat After Me':
        return 'Listen to the correct pronunciation first, then record yourself saying the word exactly as you heard it.';
      case 'Tap & Listen':
        return 'Tap the listen button to hear the correct pronunciation multiple times. Focus on the sound patterns.';
      case 'Phoneme Fix':
        return 'This word contains a common pronunciation error. Listen carefully to the correct version and focus on the highlighted phoneme when you repeat it.';
      case 'Word Matching':
        return 'Listen to the audio and identify the correct word. Record yourself saying it properly.';
      case 'Slow & Fast Mode':
        return 'Listen to the slow version first, then try the faster version. Record at both speeds to practice.';
      case 'Vowel Focus':
        return 'Focus on the vowel sound in this word. Pay attention to how your mouth and lips are positioned.';
      case 'Consonant Challenge':
        return 'This word focuses on a particular consonant sound. Pay attention to tongue position and airflow.';
      case 'Minimal Pairs Game':
        return 'Practice distinguishing between similar-sounding words that differ by just one sound.';
      case 'Rhyme Time':
        return 'Listen to the word and practice saying other words that rhyme with it to reinforce the sound pattern.';
      case 'Listen & Choose':
        return 'Listen to multiple pronunciations and identify the correct one. Then record yourself saying the word correctly.';
      default:
        return 'Listen carefully to the audio pronunciation and record yourself saying the word.';
    }
  }

  void _toggleAudio() {
    setState(() {
      _isPlaying = !_isPlaying;

      // In a real app, you would implement actual audio playback functionality here
      if (_isPlaying) {
        // Start audio playback
        _recordingStatus = 'Playing audio...';

        // Simulate audio playback ending after 2 seconds
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _recordingStatus = '';
            });
          }
        });
      } else {
        // Stop audio playback
        _recordingStatus = '';
      }
    });
  }

  void _toggleRecording() {
    setState(() {
      if (_isRecording) {
        // Stop recording
        _isRecording = false;
        _hasRecorded = true;
        _recordingStatus = 'Recording saved! ✓';

        // In a real app, you would implement actual recording functionality here
        // and process the recorded audio for feedback

        // Simulate processing delay
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _recordingStatus = 'Great pronunciation! ✓';
            });
          }
        });
      } else {
        // Start recording
        _isRecording = true;
        _recordingStatus = 'Recording... speak now';

        // Simulate recording for 3 seconds
        Future.delayed(Duration(seconds: 3), () {
          if (mounted && _isRecording) {
            _toggleRecording();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // Clean up resources when widget is disposed
    // In a real app, you would release audio players and recorders here
    super.dispose();
  }
}
