import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:skill_boost/helpers/storage.dart';
import 'package:skill_boost/models/pronunciationfeedback_model.dart';
import 'package:skill_boost/providers/pronunciationfeedback_provider.dart';

class PronunciationFeedbackScreen extends StatefulWidget {
  final String submissionId;
  final String lessonName;

  const PronunciationFeedbackScreen({
    Key? key,
    required this.submissionId,
    required this.lessonName,
  }) : super(key: key);

  @override
  State<PronunciationFeedbackScreen> createState() =>
      _PronunciationFeedbackScreenState();
}

class _PronunciationFeedbackScreenState
    extends State<PronunciationFeedbackScreen> {
  final SecureStorage _secureStorage = SecureStorage();
  bool _isLoading = true;
  bool _isPolling = false;
  String _error = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingUrl;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String audioUrl) async {
    try {
      // If the same audio is already playing, stop it
      if (_currentlyPlayingUrl == audioUrl) {
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingUrl = null;
        });
        return;
      }

      // Stop any currently playing audio
      await _audioPlayer.stop();

      // Set the audio source and play
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();

      setState(() {
        _currentlyPlayingUrl = audioUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing audio: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadFeedback() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final provider =
          Provider.of<PronunciationFeedbackProvider>(context, listen: false);
      final success = await provider.getSubmissionById(widget.submissionId);

      if (success) {
        final submission = provider.currentSubmission;

        // If the submission is still processing, poll for updates
        if (submission != null && submission.status == 'processing') {
          _startPolling();
        }
      } else {
        setState(() {
          _error = provider.error;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startPolling() {
    setState(() {
      _isPolling = true;
    });

    // Poll every 5 seconds
    Future.delayed(const Duration(seconds: 5), () async {
      if (!mounted) return;

      final provider =
          Provider.of<PronunciationFeedbackProvider>(context, listen: false);
      await provider.getSubmissionById(widget.submissionId);

      // If still processing, continue polling
      if (provider.currentSubmission?.status == 'processing') {
        _startPolling();
      } else {
        setState(() {
          _isPolling = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback - ${widget.lessonName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildFeedbackContent(),
    );
  }

  Widget _buildFeedbackContent() {
    final provider = Provider.of<PronunciationFeedbackProvider>(context);
    final submission = provider.currentSubmission;

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFeedback,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (submission == null) {
      return const Center(child: Text('No feedback available'));
    }

    // If still processing
    if (submission.status == 'processing') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Your pronunciation is being analyzed...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a few minutes. Please wait.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // If no feedback items
    if (submission.recordings == null || submission.recordings!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 48, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'No feedback available for this submission.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadFeedback,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // Display feedback
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeedbackHeader(submission),
          const SizedBox(height: 16),
          ...submission.recordings!
              .map((item) => _buildFeedbackItem(item))
              .toList(),
          const SizedBox(height: 24),
          _buildOverallSummary(submission),
        ],
      ),
    );
  }

  Widget _buildFeedbackHeader(PronunciationSubmission submission) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pronunciation Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lesson: ${submission.lessonName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Completed on: ${submission.submittedAt.toString().substring(0, 16)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Words completed: ${submission.recordings?.length ?? 0}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackItem(FeedbackRecording item) {
    // Calculate color based on accuracy
    Color getAccuracyColor(int accuracy) {
      if (accuracy >= 90) return Colors.green;
      if (accuracy >= 75) return Colors.orange;
      return Colors.red;
    }

    final bool isCurrentlyPlaying = _currentlyPlayingUrl == item.audioUrl;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.word,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getAccuracyColor(item.accuracy),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${item.accuracy}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (item.transcript.isNotEmpty) ...[
              Text(
                'Transcription:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                item.transcript,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Feedback:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              item.feedback,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (item.audioUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _playAudio(item.audioUrl),
                icon: Icon(isCurrentlyPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(isCurrentlyPlaying ? 'Stop' : 'Play Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrentlyPlaying
                      ? Colors.red
                      : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverallSummary(PronunciationSubmission submission) {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Average accuracy: ${submission.overallAccuracy}%',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${submission.passed ? 'Passed' : 'Not Passed'}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: submission.passed ? Colors.green : Colors.red,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              _getSummaryMessage(submission.overallAccuracy),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Lessons'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSummaryMessage(int averageAccuracy) {
    if (averageAccuracy >= 90) {
      return 'Excellent work! Your pronunciation is very good. Keep practicing to maintain this level.';
    } else if (averageAccuracy >= 75) {
      return 'Good job! Your pronunciation is generally good but there\'s still room for improvement. Focus on the specific suggestions.';
    } else if (averageAccuracy >= 50) {
      return 'You\'re making progress, but your pronunciation needs more work. Review the feedback for each word and practice regularly.';
    } else if (averageAccuracy > 0) {
      return 'Your pronunciation needs significant improvement. Don\'t worry - with regular practice and following the suggestions, you\'ll get better!';
    } else {
      return 'Practice makes perfect! Continue working on your pronunciation skills.';
    }
  }
}
