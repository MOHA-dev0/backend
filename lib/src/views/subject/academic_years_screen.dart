import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/subject_service.dart';
import 'subject_detail_screen.dart';

class AcademicYearsScreen extends StatefulWidget {
  const AcademicYearsScreen({super.key});

  @override
  State<AcademicYearsScreen> createState() => _AcademicYearsScreenState();
}

class _AcademicYearsScreenState extends State<AcademicYearsScreen> {
  final SubjectService _subjectService = SubjectService();
  bool _isLoading = true;
  List<dynamic> _academicYears = [];
  String? _errorMessage;
  int _selectedYearIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final years = await _subjectService.getAcademicYears();
      setState(() {
        _academicYears = years;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ أثناء تحميل البيانات';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'المقررات الدراسية',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1877F2),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.cairo(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: _loadData,
                    child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildYearSelector(),
                Expanded(child: _buildContent()),
              ],
            ),
    );
  }

  Widget _buildYearSelector() {
    if (_academicYears.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 70, // Increased height for better tap area
      color: const Color(0xFF1877F2), // Blue background
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _academicYears.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final year = _academicYears[index];
          final isSelected = index == _selectedYearIndex;

          return GestureDetector(
            onTap: () => setState(() => _selectedYearIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 0),
              alignment: Alignment.center,
              width: isSelected ? null : 46, // Circle if not selected
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: isSelected
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          year['name'] ?? '',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1877F2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Color(0xFF1877F2),
                        ),
                      ],
                    )
                  : Text(
                      '${index + 1}', // Show number for unselected
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1877F2),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_academicYears.isEmpty) {
      return Center(
        child: Text(
          'لا توجد سنوات دراسية',
          style: GoogleFonts.cairo(color: Colors.grey),
        ),
      );
    }

    // Safety check for index
    if (_selectedYearIndex >= _academicYears.length) {
      _selectedYearIndex = 0;
    }

    // Get subjects for selected year
    final currentYear = _academicYears[_selectedYearIndex];
    final List subjects = currentYear['subjects'] ?? [];

    // Filter by type (Gold / Silver)
    // We filter using the strict key 'gold' or 'silver' from backend
    final goldSubjects = subjects
        .where(
          (s) => (s['course_type'] ?? '').toString().toLowerCase() == 'gold',
        )
        .toList();

    final silverSubjects = subjects
        .where(
          (s) => (s['course_type'] ?? '').toString().toLowerCase() == 'silver',
        )
        .toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 1), // small separator
            child: TabBar(
              labelStyle: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              unselectedLabelStyle: GoogleFonts.cairo(
                fontWeight: FontWeight.normal,
              ),
              labelColor: const Color(0xFF1877F2),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF1877F2),
              tabs: const [
                Tab(text: 'المقرر الذهبي'),
                Tab(text: 'المقرر الفضي'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSubjectsGrid(goldSubjects, isGold: true),
                _buildSubjectsGrid(silverSubjects, isGold: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsGrid(List subjects, {required bool isGold}) {
    if (subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'لا توجد مواد للعرض',
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8, // Adjusted ratio
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return _buildSubjectCard(
              subject,
              isGold: isGold,
            ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1);
          },
        ),
      ],
    );
  }

  Widget _buildSubjectCard(
    Map<String, dynamic> subject, {
    required bool isGold,
  }) {
    final borderColor = isGold
        ? const Color(0xFFD4AF37)
        : const Color(0xFFC0C0C0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectDetailScreen(
              subjectId: subject['id'],
              title: subject['name'] ?? 'تفاصيل المادة',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: subject['image'] != null
                    ? Image.network(
                        subject['image'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.menu_book,
                            size: 40,
                            color: borderColor,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.menu_book,
                          size: 40,
                          color: borderColor,
                        ),
                      ),
              ),
            ),

            // Info
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subject['name'] ?? '',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1565C0),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Code or other info (Removed Exam Type as requested)
                    if (subject['code'] != null)
                      Text(
                        '${subject['code']}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),

                    // Price
                    Text(
                      '${subject['price_unit'] ?? 0} ل.س',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: borderColor,
                      ),
                    ),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubjectDetailScreen(
                                subjectId: subject['id'],
                                title: subject['name'] ?? 'تفاصيل المادة',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: borderColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'عرض',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
