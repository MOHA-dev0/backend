import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/constants/env_config.dart';
import '../../core/helpers/url_helper.dart';

class UnitAudioScreen extends StatefulWidget {
  final Map<String, dynamic> unit;

  const UnitAudioScreen({super.key, required this.unit});

  @override
  State<UnitAudioScreen> createState() => _UnitAudioScreenState();
}

class _UnitAudioScreenState extends State<UnitAudioScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isAudioLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _audioError;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();

    // Auto load if url exists
    final audioUrl = widget.unit['audio_url'];
    if (audioUrl != null && audioUrl.isNotEmpty) {
      _loadAndPlayAudio(audioUrl, autoPlay: false);
    }
  }

  void _setupAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isAudioLoading =
              state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });

    _audioPlayer.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _audioPlayer.durationStream.listen((dur) {
      if (mounted && dur != null) setState(() => _duration = dur);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // ...

  String _buildFileUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final base = EnvConfig.apiBaseUrl.replaceAll('/api', '');

    // Use cors-storage for Web to ensure playback, storage for native
    if (kIsWeb) {
      return UrlHelper.fixUrl('$base/cors-storage/$path');
    }
    return UrlHelper.fixUrl('$base/storage/$path');
  }

  Future<void> _loadAndPlayAudio(
    String audioPath, {
    bool autoPlay = true,
  }) async {
    try {
      setState(() {
        _audioError = null;
        _isAudioLoading = true;
      });

      final url = _buildFileUrl(audioPath);
      await _audioPlayer.setUrl(url);
      if (autoPlay) {
        await _audioPlayer.play();
      }

      setState(() => _isAudioLoading = false);
    } catch (e) {
      debugPrint('Audio Error: $e');
      if (mounted) {
        setState(() {
          _audioError = 'فشل تشغيل الصوت';
          _isAudioLoading = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _seekTo(Duration position) {
    _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.unit['title'] ?? 'الوحدة';
    final String audioTitle = widget.unit['audio_title'] ?? 'الملخص الصوتي';
    final bool hasLoaded = _duration > Duration.zero;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'التسجيلات الصوتية',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(
          0xFFC0CA33,
        ), // Olive/Gold for Audio?? Or blue? User implies separation. Let's stick to theme.
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon / Visualization
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFFC0CA33).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.headphones,
                size: 80,
                color: Color(0xFFC0CA33),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              title,
              style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              audioTitle,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Error
            if (_audioError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _audioError!,
                  style: GoogleFonts.cairo(color: Colors.red),
                ),
              ),

            // Progress Slider
            if (hasLoaded) ...[
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFFC0CA33),
                  inactiveTrackColor: Colors.grey[200],
                  thumbColor: const Color(0xFFC0CA33),
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                ),
                child: Slider(
                  value: _position.inSeconds.toDouble().clamp(
                    0,
                    _duration.inSeconds.toDouble(),
                  ),
                  max: _duration.inSeconds.toDouble().clamp(1, double.infinity),
                  onChanged: (value) =>
                      _seekTo(Duration(seconds: value.toInt())),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rewind 10s
                IconButton(
                  icon: const Icon(
                    Icons.replay_10_rounded,
                    size: 36,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    final newPos = _position - const Duration(seconds: 10);
                    _seekTo(newPos < Duration.zero ? Duration.zero : newPos);
                  },
                ),
                const SizedBox(width: 24),

                // Play/Pause
                GestureDetector(
                  onTap: _isAudioLoading ? null : _togglePlayPause,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0CA33),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC0CA33).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _isAudioLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                  ),
                ),

                const SizedBox(width: 24),

                // Forward 10s
                IconButton(
                  icon: const Icon(
                    Icons.forward_10_rounded,
                    size: 36,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    final newPos = _position + const Duration(seconds: 10);
                    _seekTo(newPos > _duration ? _duration : newPos);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
