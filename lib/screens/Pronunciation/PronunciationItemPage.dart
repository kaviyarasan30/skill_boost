import 'package:flutter/material.dart';
import 'package:skill_boost/api/profile_service.dart';
import 'dart:async';
import 'package:skill_boost/models/pronunciation_lesson_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';

// Add this class to store recording data
class RecordingData {
  final String questionId;
  final String recordingPath;
  final DateTime timestamp;

  RecordingData({
    required this.questionId,
    required this.recordingPath,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'recordingPath': recordingPath,
        'timestamp': timestamp.toIso8601String(),
      };
}

class PronunciationItemPage extends StatefulWidget {
  final PronunciationItem pronunciationItem;
  final String lessonName;
  final int totalItems;
  final int currentIndex;
  final String lessonId;
  final Map<int, RecordingData> previousRecordings;

  const PronunciationItemPage({
    Key? key,
    required this.pronunciationItem,
    required this.lessonName,
    required this.totalItems,
    required this.currentIndex,
    required this.lessonId,
    this.previousRecordings = const {},
  }) : super(key: key);

  @override
  _PronunciationItemPageState createState() => _PronunciationItemPageState();
}

class _PronunciationItemPageState extends State<PronunciationItemPage>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  bool _hasRecorded = false;
  bool _hasListened = false;
  bool _isRecording = false;
  String _recordingStatus = '';
  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  late AnimationController _animationController;
  bool _showWord = false;
  // Add this to store recordings
  final Map<int, RecordingData> _recordings = {};
  String? _userId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initAudioPlayer();
    _loadUserId();
    // Load previous recordings
    _recordings.addAll(widget.previousRecordings);
  }

  Future<void> _initAudioPlayer() async {
    try {
      _audioPlayer = AudioPlayer();

      // Configure audio player settings
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

      // Create the source
      final source = UrlSource(widget.pronunciationItem.audioFile);

      try {
        await _audioPlayer.setSource(source).timeout(
          Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Failed to load audio file');
          },
        );

        _isInitialized = true;
      } catch (e) {
        print('Error setting source: $e');
        throw 'Failed to set audio source: ${e.toString()}';
      }

      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
            if (state == PlayerState.completed) {
              _recordingStatus = '';
            }
          });
        }
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _recordingStatus = '';
          });
        }
      });
    } catch (e) {
      print('Error initializing audio player: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _recordingStatus =
              'Error loading audio. Please check your internet connection.';
        });
      }
    }
  }

  Future<void> _toggleAudio() async {
    if (!_isInitialized) {
      await _initAudioPlayer();
      if (!_isInitialized) {
        setState(() {
          _recordingStatus = 'Cannot play audio. Please try again later.';
        });
        return;
      }
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _recordingStatus = '';
        });
      } else {
        setState(() {
          _recordingStatus = 'Playing audio...';
        });

        await _audioPlayer.stop();
        final source = UrlSource(widget.pronunciationItem.audioFile);
        await _audioPlayer.setSource(source);
        await _audioPlayer.resume();

        setState(() {
          _hasListened = true;
        });
      }
    } catch (e) {
      print('Error playing audio: $e');
      setState(() {
        _isPlaying = false;
        _recordingStatus = 'Error playing audio. Please try again.';
      });
      _isInitialized = false;
      await _initAudioPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return recordings when back button is pressed
        Navigator.of(context).pop({'recordings': _recordings});
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
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
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
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
                child: IconButton(
                  icon: const Icon(Icons.help_outline,
                      color: Colors.black, size: 20),
                  onPressed: () {
                    // Show help dialog
                    showDialog(
                      context: context,
                      builder: (context) => _buildInstructionsDialog(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildExerciseHeader(),
                    Expanded(child: _buildExerciseContent()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple[700]!,
            Colors.purple[900]!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.lessonName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Exercise ${widget.currentIndex + 1} of ${widget.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${((widget.currentIndex + 1) / widget.totalItems * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                LinearProgressIndicator(
                  value: (widget.currentIndex + 1) / widget.totalItems,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
                Positioned.fill(
                  child: Row(
                    children: List.generate(
                      widget.totalItems,
                      (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getTypeColor(widget.pronunciationItem.type).withOpacity(0.15),
            _getTypeColor(widget.pronunciationItem.type).withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getTypeColor(widget.pronunciationItem.type)
                          .withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  _getTypeIcon(widget.pronunciationItem.type),
                  color: _getTypeColor(widget.pronunciationItem.type),
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pronunciationItem.type,
                      style: TextStyle(
                        color: _getTypeColor(widget.pronunciationItem.type),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.pronunciationItem.hint,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_showWord) ...[
            const Text(
              'The word was:',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple[50]!,
                    Colors.purple[100]!.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.purple[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple[100]!.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                widget.pronunciationItem.word,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[900],
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                onTap: _toggleAudio,
                icon: _isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Colors.blue[700]!,
                label: 'Listen',
                isActive: _isPlaying,
                isDone: _hasListened,
              ),
              const SizedBox(width: 40),
              _buildControlButton(
                onTap: _hasListened ? _toggleRecording : null,
                icon: _isRecording ? Icons.stop_circle : Icons.mic,
                color: _isRecording ? Colors.red : Colors.green[700]!,
                label: _isRecording ? 'Stop' : 'Record',
                isActive: _isRecording,
                isDone: _hasRecorded,
                isDisabled: !_hasListened,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_recordingStatus.isNotEmpty)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: (_hasRecorded ? Colors.green[50] : Colors.blue[50])!,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (_hasRecorded ? Colors.green : Colors.blue)[100]!
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _hasRecorded ? Icons.check_circle : Icons.info_outline,
                    color: _hasRecorded ? Colors.green[700] : Colors.blue[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _recordingStatus,
                    style: TextStyle(
                      color:
                          _hasRecorded ? Colors.green[700] : Colors.blue[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          if (_hasRecorded)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: () {
                  if (widget.currentIndex < widget.totalItems - 1) {
                    Navigator.of(context).pop({
                      'nextIndex': widget.currentIndex + 1,
                      'recordings': _recordings,
                    });
                  } else {
                    _showCompletionDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.currentIndex < widget.totalItems - 1
                          ? 'Next Exercise'
                          : 'Complete Lesson',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      widget.currentIndex < widget.totalItems - 1
                          ? Icons.arrow_forward
                          : Icons.check_circle,
                      size: 24,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onTap,
    required IconData icon,
    required Color color,
    required String label,
    bool isActive = false,
    bool isDone = false,
    bool isDisabled = false,
  }) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(isActive ? 0.5 : 0.2),
                  width: 2,
                ),
                boxShadow: [
                  if (isActive)
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: color, size: 44),
                  if (isDone)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleRecording() {
    setState(() {
      if (_isRecording) {
        _isRecording = false;
        _hasRecorded = true;
        _recordingStatus = 'Recording saved! ✓';
        _showWord = true;

        // Store recording data with current question index
        _recordings[widget.currentIndex] = RecordingData(
          questionId: widget.pronunciationItem.id ?? 'unknown',
          recordingPath:
              'recording_${widget.lessonId}_${widget.currentIndex}.mp3',
          timestamp: DateTime.now(),
        );

        // Print debug info for verification
        print(
            'Recording saved for question ${widget.currentIndex + 1}/${widget.totalItems}');
        print('Current recordings count: ${_recordings.length}');

        // Auto-navigate after showing the word
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _hasRecorded) {
            setState(() {
              _showWord = false;
            });
          }
        });
      } else {
        _isRecording = true;
        _recordingStatus = 'Recording... speak now';

        // Simulate recording for 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _isRecording) {
            _toggleRecording();
          }
        });
      }
    });
  }

  void _logLessonCompletion() {
    // Sort recordings by index to ensure proper order
    final sortedRecordings = List.generate(widget.totalItems, (index) {
      return _recordings[index]?.toJson() ??
          {
            'questionId': 'unknown',
            'recordingPath': 'missing_recording_$index',
            'timestamp': DateTime.now().toIso8601String()
          };
    });

    // Create completion data
    final completionData = {
      'userId': _userId ?? 'unknown',
      'lessonId': widget.lessonId,
      'lessonName': widget.lessonName,
      'completedAt': DateTime.now().toIso8601String(),
      'totalQuestions': widget.totalItems,
      'completedQuestions': _recordings.length,
      'recordings': sortedRecordings
    };

    // Log only the data that would be sent to backend
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    print(encoder.convert(completionData));
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCompletionDialog(),
    );
  }

  Widget _buildCompletionDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.purple[700],
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Lesson Completed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Great job! You\'ve completed all ${widget.totalItems} exercises in this lesson.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Log completion data before navigating
                      _logLessonCompletion();

                      // Pop with recordings data
                      Navigator.of(context)
                        ..pop() // Close dialog
                        ..pop(
                            _recordings); // Return to lesson list with recordings
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Return to Lessons',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getTypeColor(widget.pronunciationItem.type)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTypeIcon(widget.pronunciationItem.type),
                color: _getTypeColor(widget.pronunciationItem.type),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.pronunciationItem.type,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getTypeColor(widget.pronunciationItem.type),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getInstructions(widget.pronunciationItem.type),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Repeat After Me':
        return Icons.volume_up;
      case 'Tap & Listen':
        return Icons.mic;
      case 'Phoneme Fix':
        return Icons.error;
      case 'Word Matching':
        return Icons.check;
      case 'Slow & Fast Mode':
        return Icons.speed;
      case 'Vowel Focus':
        return Icons.volume_up;
      case 'Consonant Challenge':
        return Icons.error;
      case 'Minimal Pairs Game':
        return Icons.compare_arrows;
      case 'Rhyme Time':
        return Icons.music_note;
      case 'Listen & Choose':
        return Icons.mic;
      default:
        return Icons.volume_up;
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

  Future<void> _loadUserId() async {
    try {
      final profileService = ProfileService();
      final userId = await profileService.getCurrentUserId();
      if (mounted) {
        setState(() {
          _userId = userId ?? 'unknown';
        });
      }
      if (userId == null) {
        print('Warning: No user ID found in SharedPreferences');
      }
    } catch (e) {
      print('Error loading user ID: $e');
      if (mounted) {
        setState(() {
          _userId = 'unknown';
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
