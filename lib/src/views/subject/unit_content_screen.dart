import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/env_config.dart';
import '../../core/helpers/url_helper.dart';

class UnitContentScreen extends StatefulWidget {
  final int unitId;
  final String unitTitle;
  final String? googleDocUrl;
  final String? fileUrl; // For uploaded files
  final int pageCount;

  const UnitContentScreen({
    super.key,
    required this.unitId,
    required this.unitTitle,
    this.googleDocUrl,
    this.fileUrl,
    this.pageCount = 0,
  });

  @override
  State<UnitContentScreen> createState() => _UnitContentScreenState();
}

class _UnitContentScreenState extends State<UnitContentScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _urlLaunched = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  /// Get the content URL - prioritize google_doc_url, fallback to file_url
  String? _getContentUrl() {
    // First check google_doc_url
    if (widget.googleDocUrl != null && widget.googleDocUrl!.isNotEmpty) {
      return widget.googleDocUrl;
    }

    // Then check file_url (uploaded file)
    if (widget.fileUrl != null && widget.fileUrl!.isNotEmpty) {
      // Build full URL for uploaded file
      String fileUrl = widget.fileUrl!;
      if (!fileUrl.startsWith('http')) {
        fileUrl =
            '${EnvConfig.apiBaseUrl.replaceAll('/api', '')}/cors-storage/$fileUrl';
      }
      return UrlHelper.fixUrl(fileUrl);
    }

    return null;
  }

  Future<void> _loadContent() async {
    final contentUrl = _getContentUrl();

    if (contentUrl == null) {
      setState(() {
        _errorMessage = 'لا يوجد محتوى متاح لهذه الوحدة';
        _isLoading = false;
      });
      return;
    }

    // Open in browser
    await _launchInBrowser(contentUrl);
  }

  Future<void> _launchInBrowser([String? url]) async {
    try {
      String targetUrl = url ?? _getContentUrl()!;
      targetUrl = _getEmbedUrl(targetUrl);
      final uri = Uri.parse(targetUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        setState(() {
          _isLoading = false;
          _urlLaunched = true;
        });
      } else {
        setState(() {
          _errorMessage = 'لا يمكن فتح الرابط';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل فتح المحتوى: $e';
        _isLoading = false;
      });
    }
  }

  String _getEmbedUrl(String url) {
    // For browser viewing, use regular view URL
    if (url.contains('docs.google.com/document')) {
      // Convert to view mode if needed
      if (!url.contains('/view') && !url.contains('/preview')) {
        return url.replaceAll('/edit', '/view');
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.unitTitle,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1877F2),
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          if (widget.pageCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.menu_book,
                      size: 18,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.pageCount} صفحة',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_errorMessage != null) ...[
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _isLoading = true;
                    });
                    _loadContent();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                  ),
                ),
              ] else if (_urlLaunched) ...[
                const Icon(
                  Icons.open_in_browser,
                  size: 64,
                  color: Color(0xFF1877F2),
                ),
                const SizedBox(height: 16),
                Text(
                  'تم فتح المحتوى في المتصفح',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'يمكنك العودة للتطبيق بعد الانتهاء من القراءة',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: Text('العودة', style: GoogleFonts.cairo()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _launchInBrowser(),
                      icon: const Icon(Icons.refresh),
                      label: Text('فتح مرة أخرى', style: GoogleFonts.cairo()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
