import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/env_config.dart';
import '../../core/helpers/url_helper.dart';

class AudioPlayerScreen extends StatefulWidget {
  final int unitId;
  final String unitTitle;
  final String audioUrl;
  final String? audioTitle;
  final int? audioDuration; // in seconds

  const AudioPlayerScreen({
    super.key,
    required this.unitId,
    required this.unitTitle,
    required this.audioUrl,
    this.audioTitle,
    this.audioDuration,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      // Build full URL
      String fullUrl = widget.audioUrl;
      if (!fullUrl.startsWith('http')) {
        fullUrl =
            '${EnvConfig.apiBaseUrl.replaceAll('/api', '')}/cors-storage/${widget.audioUrl}';
      }
      fullUrl = UrlHelper.fixUrl(fullUrl);

      debugPrint('Audio URL: $fullUrl');

      // On Windows, open in browser since video_player may not support audio
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        setState(() {
          _isLoading = false;
        });
        // Will show manual play button
        return;
      }

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(fullUrl),
      );
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        showControls: false, // We'll use custom controls
        aspectRatio: 16 / 9,
      );

      _videoPlayerController!.addListener(_onPlayerUpdate);

      setState(() {
        _isLoading = false;
        _duration = _videoPlayerController!.value.duration;
      });
    } catch (e) {
      debugPrint('Audio Player Error: $e');
      setState(() {
        _errorMessage = 'فشل تحميل الصوت';
        _isLoading = false;
      });
    }
  }

  void _onPlayerUpdate() {
    if (_videoPlayerController == null) return;
    setState(() {
      _isPlaying = _videoPlayerController!.value.isPlaying;
      _position = _videoPlayerController!.value.position;
      _duration = _videoPlayerController!.value.duration;
    });
  }

  void _togglePlayPause() {
    if (_videoPlayerController == null) return;
    if (_isPlaying) {
      _videoPlayerController!.pause();
    } else {
      _videoPlayerController!.play();
    }
  }

  void _seekTo(Duration position) {
    _videoPlayerController?.seekTo(position);
  }

  Future<void> _openInBrowser() async {
    String fullUrl = widget.audioUrl;
    if (!fullUrl.startsWith('http')) {
      fullUrl =
          '${EnvConfig.apiBaseUrl.replaceAll('/api', '')}/cors-storage/${widget.audioUrl}';
    }
    fullUrl = UrlHelper.fixUrl(fullUrl);

    final uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      final hours = twoDigits(duration.inHours);
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_onPlayerUpdate);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1877F2),
      appBar: AppBar(
        title: Text(
          widget.audioTitle ?? 'الملخص الصوتي',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Unit Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                widget.unitTitle,
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            // Audio Title
            if (widget.audioTitle != null)
              Text(
                widget.audioTitle!,
                style: GoogleFonts.cairo(fontSize: 16, color: Colors.white70),
              ),

            const Spacer(),

            // Audio Icon/Visualization
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.graphic_eq : Icons.headphones,
                size: 100,
                color: Colors.white,
              ),
            ),

            const Spacer(),

            if (_isLoading)
              const CircularProgressIndicator(color: Colors.white)
            else if (_errorMessage != null)
              _buildErrorWidget()
            else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
              _buildDesktopPlayer()
            else
              _buildMobilePlayer(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      children: [
        Text(_errorMessage!, style: GoogleFonts.cairo(color: Colors.white70)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _errorMessage = null;
              _isLoading = true;
            });
            _initAudioPlayer();
          },
          icon: const Icon(Icons.refresh),
          label: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1877F2),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopPlayer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'اضغط للاستماع في المتصفح',
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openInBrowser,
            icon: const Icon(Icons.play_arrow, size: 32),
            label: Text('تشغيل الصوت', style: GoogleFonts.cairo(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0CA33),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePlayer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Progress Bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFC0CA33),
              inactiveTrackColor: Colors.white24,
              thumbColor: const Color(0xFFC0CA33),
              trackHeight: 4,
            ),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble().clamp(1, double.infinity),
              onChanged: (value) {
                _seekTo(Duration(seconds: value.toInt()));
              },
            ),
          ),

          // Time Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: GoogleFonts.cairo(color: Colors.white70),
                ),
                Text(
                  _formatDuration(_duration),
                  style: GoogleFonts.cairo(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Play/Pause Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rewind 10s
              IconButton(
                onPressed: () {
                  final newPosition = _position - const Duration(seconds: 10);
                  _seekTo(
                    newPosition < Duration.zero ? Duration.zero : newPosition,
                  );
                },
                icon: const Icon(
                  Icons.replay_10,
                  color: Colors.white,
                  size: 36,
                ),
              ),

              const SizedBox(width: 16),

              // Play/Pause
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFC0CA33),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Forward 10s
              IconButton(
                onPressed: () {
                  final newPosition = _position + const Duration(seconds: 10);
                  _seekTo(newPosition > _duration ? _duration : newPosition);
                },
                icon: const Icon(
                  Icons.forward_10,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
