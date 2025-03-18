import 'package:flutter/material.dart';
import 'package:skill_boost/api/profile_service.dart';
import 'dart:async';
import 'package:skill_boost/models/pronunciation_lesson_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:skill_boost/providers/pronunciationfeedback_provider.dart';
import 'package:skill_boost/screens/Pronunciation/PronunciationFeedbackScreen.dart';
import 'package:record/record.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// Add this class to store recording data
class RecordingData {
  final String questionId;
  final String recordingPath;
  final DateTime timestamp;
  final File? audioFile;
  final String word;

  RecordingData({
    required this.questionId,
    required this.recordingPath,
    required this.timestamp,
    this.audioFile,
    required this.word,
  }) {
    // Validate data at construction time
    if (questionId.trim().isEmpty) {
      throw ArgumentError('questionId cannot be empty');
    }
    if (recordingPath.trim().isEmpty) {
      throw ArgumentError('recordingPath cannot be empty');
    }
    if (word.trim().isEmpty) {
      throw ArgumentError('word cannot be empty');
    }
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId.trim(),
        'recordingPath': recordingPath.trim(),
        'timestamp': timestamp.toIso8601String(),
        'audioFile': audioFile,
        'word': word.trim(),
      };

  @override
  String toString() {
    return 'RecordingData(questionId: $questionId, recordingPath: $recordingPath, timestamp: $timestamp, audioFile: ${audioFile?.path}, word: $word)';
  }
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
  late final AudioRecorder _audioRecorder;
  Timer? _wordTimer;
  Map<int, RecordingData> _recordings = {};
  int _currentIndex = 0;
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
    _requestPermissions();
    _audioRecorder = AudioRecorder();
    _recordings.addAll(widget.previousRecordings);
    _currentIndex = widget.currentIndex;
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

  Future<void> _requestPermissions() async {
    try {
      final status = await Permission.microphone.status;

      if (status.isDenied || status.isRestricted) {
        // Show a dialog explaining why we need the permission
        final shouldShowRationale = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.mic, color: Colors.purple[700]),
                const SizedBox(width: 10),
                const Text('Microphone Access Needed'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'To practice pronunciation, we need access to your microphone to:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildPermissionItem(
                  icon: Icons.record_voice_over,
                  text: 'Record your pronunciation',
                ),
                _buildPermissionItem(
                  icon: Icons.compare_arrows,
                  text: 'Compare with correct pronunciation',
                ),
                _buildPermissionItem(
                  icon: Icons.feedback,
                  text: 'Provide accurate feedback',
                ),
                const SizedBox(height: 12),
                Text(
                  'You can change this permission anytime in your device settings.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Not Now'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                ),
                child: const Text('Allow Access'),
              ),
            ],
          ),
        );

        if (shouldShowRationale == true) {
          final permissionStatus = await Permission.microphone.request();
          if (!permissionStatus.isGranted) {
            if (mounted) {
              // Show settings dialog if permission is denied
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.purple[700]),
                      const SizedBox(width: 10),
                      const Text('Enable Microphone'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'To enable microphone access:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsInstructionItem(
                        number: '1',
                        text: 'Open device Settings',
                      ),
                      _buildSettingsInstructionItem(
                        number: '2',
                        text: 'Go to Apps / Application Manager',
                      ),
                      _buildSettingsInstructionItem(
                        number: '3',
                        text: 'Find "Skill Boost" app',
                      ),
                      _buildSettingsInstructionItem(
                        number: '4',
                        text: 'Tap Permissions',
                      ),
                      _buildSettingsInstructionItem(
                        number: '5',
                        text: 'Enable Microphone',
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => openAppSettings(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                      ),
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  Widget _buildPermissionItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.purple[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsInstructionItem(
      {required String number, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.purple[700],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Future<String> _getRecordingPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${appDir.path}/recording_${widget.lessonId}_${widget.currentIndex}_$timestamp.m4a';
  }

  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        // Stop recording
        final recordingPath = await _audioRecorder.stop();

        if (recordingPath == null || recordingPath.isEmpty) {
          print('Warning: No recording path received');
          setState(() {
            _recordingStatus = 'Recording failed. Please try again.';
            _isRecording = false;
          });
          return;
        }

        final audioFile = File(recordingPath);
        if (!audioFile.existsSync()) {
          print('Warning: Audio file not found at path: $recordingPath');
          setState(() {
            _recordingStatus = 'Recording failed. Please try again.';
            _isRecording = false;
          });
          return;
        }

        // Get the current question ID
        final questionId = widget.pronunciationItem.id;
        if (questionId == null || questionId.isEmpty) {
          print(
              'Warning: Invalid questionId for current index: $_currentIndex');
          setState(() {
            _recordingStatus = 'Recording failed. Please try again.';
            _isRecording = false;
          });
          return;
        }

        // Store recording data
        try {
          _recordings[_currentIndex] = RecordingData(
            questionId: questionId,
            recordingPath: recordingPath,
            timestamp: DateTime.now(),
            audioFile: audioFile,
            word: widget.pronunciationItem.word,
          );

          print('Debug: Stored recording for index $_currentIndex:');
          print(_recordings[_currentIndex].toString());

          setState(() {
            _isRecording = false;
            _showWord = true;
            _hasRecorded = true;
            _recordingStatus = 'Recording saved successfully!';
          });

          // Auto-hide word after 3 seconds
          _wordTimer?.cancel();
          _wordTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showWord = false;
              });
            }
          });
        } catch (e) {
          print('Error storing recording data: $e');
          setState(() {
            _recordingStatus = 'Failed to save recording. Please try again.';
            _isRecording = false;
          });
          return;
        }
      } else {
        // Check and request permission before starting recording
        final status = await Permission.microphone.status;
        if (status.isDenied || status.isPermanentlyDenied) {
          await _requestPermissions();
          // Check permission status again after request
          final newStatus = await Permission.microphone.status;
          if (!newStatus.isGranted) {
            print('Warning: Microphone permission denied');
            setState(() {
              _recordingStatus = 'Microphone permission denied';
            });
            return;
          }
        }

        // Create recording path
        final recordingPath = await _getRecordingPath();

        // Start recording
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: recordingPath,
        );

        setState(() {
          _isRecording = true;
          _showWord = true;
          _recordingStatus = 'Recording in progress...';
        });
      }
    } catch (e) {
      print('Error in _toggleRecording: $e');
      setState(() {
        _isRecording = false;
        _showWord = false;
        _recordingStatus = 'Recording failed. Please try again.';
      });
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
          if (_showWord || _isRecording) ...[
            Text(
              _isRecording ? 'Recording in progress...' : 'The word was:',
              style: TextStyle(
                color: _isRecording ? Colors.red : Colors.grey,
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
                    _isRecording ? Colors.red[50]! : Colors.purple[50]!,
                    _isRecording
                        ? Colors.red[100]!.withOpacity(0.3)
                        : Colors.purple[100]!.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isRecording ? Colors.red[200]! : Colors.purple[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isRecording
                        ? Colors.red[100]!.withOpacity(0.3)
                        : Colors.purple[100]!.withOpacity(0.3),
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
                  color: _isRecording ? Colors.red[900] : Colors.purple[900],
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
                color: _isRecording
                    ? Colors.red[50]
                    : (_hasRecorded ? Colors.green[50] : Colors.blue[50])!,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording
                            ? Colors.red
                            : (_hasRecorded ? Colors.green : Colors.blue))[100]!
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
                    _isRecording
                        ? Icons.mic
                        : (_hasRecorded
                            ? Icons.check_circle
                            : Icons.info_outline),
                    color: _isRecording
                        ? Colors.red[700]
                        : (_hasRecorded ? Colors.green[700] : Colors.blue[700]),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _recordingStatus,
                    style: TextStyle(
                      color: _isRecording
                          ? Colors.red[700]
                          : (_hasRecorded
                              ? Colors.green[700]
                              : Colors.blue[700]),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          if (_hasRecorded && !_isRecording)
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
                    onPressed: () async {
                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      try {
                        // Ensure we have recordings for all questions
                        if (_recordings.isEmpty) {
                          throw Exception('No recordings available');
                        }

                        // Convert recordings to the format expected by the API
                        final List<File> audioFiles = [];
                        final List<String> wordIds = [];
                        final List<String> words = [];

                        // Sort recordings by index to ensure proper order
                        final sortedIndices = _recordings.keys.toList()..sort();

                        // Debug print each recording before processing
                        print('Debug: Recordings before processing:');
                        _recordings.forEach((key, value) {
                          print('Index: $key');
                          print('QuestionId: ${value.questionId}');
                          print('RecordingPath: ${value.recordingPath}');
                          print('Timestamp: ${value.timestamp}');
                          print(
                              'Audio File exists: ${value.audioFile?.existsSync()}');
                        });

                        for (var index in sortedIndices) {
                          final recording = _recordings[index]!;

                          // Validate each field
                          if (recording.questionId.isEmpty) {
                            throw Exception(
                                'Invalid questionId for recording at index $index');
                          }
                          if (recording.recordingPath.isEmpty) {
                            throw Exception(
                                'Invalid recordingPath for recording at index $index');
                          }
                          if (recording.timestamp == null) {
                            throw Exception(
                                'Invalid timestamp for recording at index $index');
                          }
                          if (recording.audioFile == null ||
                              !recording.audioFile!.existsSync()) {
                            throw Exception(
                                'Audio file not found for recording at index $index');
                          }

                          // Add to lists for submission
                          audioFiles.add(recording.audioFile!);
                          wordIds.add(recording.questionId);
                          words.add(recording.word);
                        }

                        // Get current user ID first
                        final userId =
                            await ProfileService().getCurrentUserId();
                        if (userId == null || userId.isEmpty) {
                          throw Exception('User ID not found');
                        }

                        // Validate all required fields
                        if (widget.lessonId.isEmpty) {
                          throw Exception('Invalid lesson ID');
                        }
                        if (widget.lessonName.isEmpty) {
                          throw Exception('Invalid lesson name');
                        }
                        if (widget.totalItems <= 0) {
                          throw Exception('Invalid total questions count');
                        }
                        if (audioFiles.isEmpty) {
                          throw Exception('No valid recordings to submit');
                        }

                        // Debug print final submission data
                        print('Debug: Final submission data:');
                        print('UserId: $userId');
                        print('LessonId: ${widget.lessonId}');
                        print('LessonName: ${widget.lessonName}');
                        print('TotalQuestions: ${widget.totalItems}');
                        print('CompletedQuestions: ${audioFiles.length}');

                        // Get the provider
                        final provider =
                            Provider.of<PronunciationFeedbackProvider>(
                          context,
                          listen: false,
                        );

                        // Submit recordings with validated data
                        final success =
                            await provider.submitPronunciationRecordings(
                          lessonId: widget.lessonId,
                          audioFiles: audioFiles,
                          wordIds: wordIds,
                          words: words,
                        );

                        // Close loading dialog
                        Navigator.of(context).pop();

                        if (success &&
                            provider.submissionId != null &&
                            provider.submissionId!.isNotEmpty) {
                          print(
                              'Submission successful. SubmissionId: ${provider.submissionId}');

                          // Clean up audio files
                          for (var recording in _recordings.values) {
                            try {
                              if (recording.audioFile != null &&
                                  recording.audioFile!.existsSync()) {
                                await recording.audioFile!.delete();
                              }
                            } catch (e) {
                              print('Error deleting audio file: $e');
                            }
                          }

                          // Close completion dialog
                          Navigator.of(context).pop();
                          // Close lesson page
                          Navigator.of(context).pop();

                          // Navigate to feedback screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PronunciationFeedbackScreen(
                                submissionId: provider.submissionId!,
                                lessonName: widget.lessonName,
                              ),
                            ),
                          );
                        } else {
                          throw Exception(provider.error.isNotEmpty
                              ? provider.error
                              : 'Failed to submit recordings: No submission ID received');
                        }
                      } catch (e) {
                        print('Error submitting recordings: $e');
                        // Close loading dialog if it's showing
                        Navigator.of(context).pop();

                        // Show error dialog with more details
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(e.toString()),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Debug Info:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('User ID: $_userId'),
                                  Text('Lesson ID: ${widget.lessonId}'),
                                  Text(
                                      'Recordings Count: ${_recordings.length}'),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
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
                          'View Feedback',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
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
    _wordTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
