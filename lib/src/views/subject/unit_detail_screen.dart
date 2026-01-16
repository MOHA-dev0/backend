import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../core/constants/env_config.dart';
import '../../core/helpers/url_helper.dart';
import 'unit_audio_screen.dart';

class UnitDetailScreen extends StatefulWidget {
  final Map<String, dynamic> unit;

  const UnitDetailScreen({super.key, required this.unit});

  @override
  State<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> {
  String? _pdfUrl;
  File? _localPdfFile;
  bool _isLoadingPdf = false;
  String? _pdfError;

  bool _isGoogleDoc = false;
  String? _googleDocUrl;
  WebViewController? _webViewController;
  bool _isWebViewSupported = false;

  // Native PDF View State
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isPdfReady = false;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _checkWebViewSupport();
    _prepareContent();
  }

  void _checkWebViewSupport() {
    if (kIsWeb) {
      setState(() => _isWebViewSupported = true);
    } else {
      final target = defaultTargetPlatform;
      if (target == TargetPlatform.android ||
          target == TargetPlatform.iOS ||
          target == TargetPlatform.macOS) {
        setState(() => _isWebViewSupported = true);
      } else {
        setState(() => _isWebViewSupported = false);
      }
    }
  }

  String _buildFileUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final base = EnvConfig.apiBaseUrl.replaceAll('/api', '');
    return UrlHelper.fixUrl('$base/cors-storage/$path');
  }

  void _prepareContent() {
    final String? googleDocUrl = widget.unit['google_doc_url'];
    final String? fileUrl = widget.unit['file_url'];

    // Prioritize PDF if fileUrl exists
    if (fileUrl != null && fileUrl.isNotEmpty) {
      final url = _buildFileUrl(fileUrl);
      _downloadAndLoadPdf(url);
      return;
    }

    // Otherwise, check for Google Doc //
    if (googleDocUrl != null && googleDocUrl.isNotEmpty) {
      setState(() {
        _isGoogleDoc = true;
        _googleDocUrl = googleDocUrl;
      });

      if (_isWebViewSupported) {
        _initWebView(googleDocUrl);
      }
    }
  }

  Future<void> _downloadAndLoadPdf(String url) async {
    if (mounted) {
      setState(() {
        _isLoadingPdf = true;
        _pdfUrl = url;
        _pdfError = null;
      });
    }

    try {
      debugPrint('Downloading PDF (Dio) from: $url');

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/temp_unit.pdf';
      final file = File(filePath);

      // Clean up old file
      if (await file.exists()) {
        await file.delete();
      }

      // Use Dio for robust download
      await Dio().download(
        url,
        filePath,
        options: Options(
          headers: {'ngrok-skip-browser-warning': 'true'},
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      if (await file.exists()) {
        // Debug: Check file header
        final bytes = await file.openRead(0, 20).first;
        final header = String.fromCharCodes(bytes);
        debugPrint('PDF Header: $header');

        if (!header.contains('%PDF')) {
          throw Exception('Invalid PDF Header: $header');
        }

        if (mounted) {
          setState(() {
            _localPdfFile = file;
            _isLoadingPdf = false;
          });
        }
      } else {
        throw Exception('File downloaded but not found on device');
      }
    } catch (e) {
      debugPrint('PDF Download Error (Dio): $e');
      if (mounted) {
        setState(() {
          _isLoadingPdf = false;
          _pdfError = e.toString();
        });
      }
    }
  }

  void _initWebView(String url) {
    try {
      final PlatformWebViewControllerCreationParams params =
          const PlatformWebViewControllerCreationParams();

      final WebViewController controller =
          WebViewController.fromPlatformCreationParams(params);

      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..loadRequest(Uri.parse(url));

      if (mounted) {
        setState(() {
          _webViewController = controller;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isWebViewSupported = false;
          _webViewController = null;
        });
      }
    }
  }

  void _openGoogleDocExternal() async {
    if (_googleDocUrl != null) {
      final uri = Uri.parse(_googleDocUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.unit['title'] ?? 'الوحدة';
    final String? audioUrl = widget.unit['audio_url'];
    final bool hasAudio = audioUrl != null && audioUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1877F2),
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          if (hasAudio)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UnitAudioScreen(unit: widget.unit),
                  ),
                );
              },
              icon: const Icon(Icons.headphones, color: Colors.white),
              tooltip: 'الاستماع للشرح الصوتي',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Google Doc View
    if (_isGoogleDoc) {
      if (_isWebViewSupported && _webViewController != null) {
        return WebViewWidget(controller: _webViewController!);
      }
      return Center(
        child: ElevatedButton.icon(
          onPressed: _openGoogleDocExternal,
          icon: const Icon(Icons.open_in_browser),
          label: Text('فتح في المتصفح', style: GoogleFonts.cairo()),
        ),
      );
    }

    // 2. Loading State
    if (_isLoadingPdf) {
      return const Center(child: CircularProgressIndicator());
    }

    // 3. Error State
    if (_pdfError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'فشل تحميل الملف',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _pdfError!,
                style: GoogleFonts.cairo(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _downloadAndLoadPdf(_pdfUrl ?? ''),
                child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Native PDF View
    if (_localPdfFile != null) {
      return Stack(
        children: [
          PDFView(
            filePath: _localPdfFile!.path,
            enableSwipe: true,
            swipeHorizontal: false, // Vertical scrolling
            autoSpacing: true,
            pageFling: true,
            pageSnap: false, // Smooth scroll
            defaultPage: 0,
            fitPolicy: FitPolicy.WIDTH,
            preventLinkNavigation: false,
            onRender: (pages) {
              setState(() {
                _totalPages = pages ?? 0;
                _isPdfReady = true;
              });
            },
            onError: (error) {
              setState(() {
                _pdfError = error.toString();
              });
            },
            onPageError: (page, error) {
              debugPrint('Page $page error: $error');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfViewController = pdfViewController;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page ?? 0;
                _totalPages = total ?? _totalPages;
              });
            },
          ),

          // Page Number Overlay
          if (_isPdfReady && _totalPages > 0)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentPage + 1} / $_totalPages',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return Center(child: Text("لا يوجد محتوى", style: GoogleFonts.cairo()));
  }
}
