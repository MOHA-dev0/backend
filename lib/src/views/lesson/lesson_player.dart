import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
import '../../core/models/lesson_model.dart';
import '../../core/providers/user_provider.dart';

class LessonPlayer extends StatefulWidget {
  final LessonModel lesson;

  const LessonPlayer({super.key, required this.lesson});

  @override
  State<LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<LessonPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.lesson.type == 'video' && widget.lesson.mediaUrl != null) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    setState(() => _isLoading = true);
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.lesson.mediaUrl!));
      await _videoController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        zoomAndPan: true,
        playbackSpeeds: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
      );
    } catch (e) {
      debugPrint('Video Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    
    return Stack(
      children: [
        // Content Layer
        if (widget.lesson.type == 'video')
          _buildVideoPlayer()
        else if (widget.lesson.type == 'pdf')
          _buildPdfViewer()
        else
          _buildTextContent(),

        // Security Watermark Layer
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.15,
              child: Center(
                child: Transform.rotate(
                  angle: -0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(10, (index) => 
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          '${user?.name ?? ''} - ${user?.phone ?? ''}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_chewieController != null && _videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      );
    }
    return const Center(child: Text('Error loading video'));
  }

  Widget _buildPdfViewer() {
    if (widget.lesson.mediaUrl == null) return const Center(child: Text('No PDF URL'));
    
    // Note: flutter_pdfview usually requires a local file. 
    // In a real app, we'd confirm if we download it first or if the package supports network (some forks do).
    // For this prototype, we'll assume we download it or use a webview, 
    // but here is the scaffold. We'll verify PDF logic later or switch to a webview if needed.
    
    return PDFView(
      filePath: widget.lesson.mediaUrl!, // Needs local path in most versions
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: false,
    ); 
  }

  Widget _buildTextContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(
        widget.lesson.content ?? 'No content',
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }
}
