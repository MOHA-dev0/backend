import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/subject_service.dart';

class ImportantLinksScreen extends StatefulWidget {
  const ImportantLinksScreen({super.key});

  @override
  State<ImportantLinksScreen> createState() => _ImportantLinksScreenState();
}

class _ImportantLinksScreenState extends State<ImportantLinksScreen> {
  int _selectedTab = 0; // 0: University, 1: Explanations
  final SubjectService _subjectService = SubjectService();
  
  List<dynamic> _allLinks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLinks();
  }

  Future<void> _fetchLinks() async {
    try {
      final links = await _subjectService.getImportantLinks();
      if (mounted) {
        setState(() {
          _allLinks = links;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _currentLinks {
    // 0 -> University Links (type: 'university')
    // 1 -> Explanation Links (type: 'explanation')
    final targetType = _selectedTab == 0 ? 'university' : 'explanation';
    return _allLinks.where((l) => l['type'] == targetType).toList();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2196F3);
    const goldColor = Color(0xFFCDC346); 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'روابط مهمة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: Colors.grey.shade300,
            child: Row(
              children: [
                _buildTabItem('روابط الشروحات', 1, goldColor),
                _buildTabItem('روابط الجامعة', 0, goldColor),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading ? const Center(child: CircularProgressIndicator()) : 
            _currentLinks.isEmpty ? Center(child: Text('لا توجد روابط حالياً', style: GoogleFonts.cairo())) :
            ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _currentLinks.length,
              itemBuilder: (context, index) {
                final link = _currentLinks[index];
                return _buildLinkButton(link['title'] ?? '', link['url'] ?? '', primaryBlue, goldColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index, Color activeColor) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.grey.shade400,
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkButton(String title, String url, Color textColor, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              // Fallback for some devices where canLaunchUrl returns false but launchUrl works
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
