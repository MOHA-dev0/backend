import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unihub_app/src/core/services/subject_service.dart';
import 'package:unihub_app/src/views/subject/subject_detail_screen.dart';

class YearContentScreen extends StatefulWidget {
  final String yearTitle;
  final int totalYears;

  const YearContentScreen({
    super.key,
    required this.yearTitle,
    this.totalYears = 4,
  });

  @override
  State<YearContentScreen> createState() => _YearContentScreenState();
}

class _YearContentScreenState extends State<YearContentScreen> {
  final SubjectService _subjectService = SubjectService();
  bool _isLoading = true;
  List<dynamic> _allSubjects = [];
  List<dynamic> _courseTypes = [];

  // State
  late String _currentYearTitle;
  late int _selectedYearIndex; // 1-based
  int? _selectedTypeId; // null = All

  final Map<int, String> _yearToTitleMap = {
    1: 'السنة الأولى',
    2: 'السنة الثانية',
    3: 'السنة الثالثة',
    4: 'السنة الرابعة',
    5: 'السنة الخامسة',
    6: 'السنة السادسة',
    7: 'السنة السابعة',
  };

  @override
  void initState() {
    super.initState();
    _currentYearTitle = widget.yearTitle;
    // reverse lookup or default
    _selectedYearIndex = _yearToTitleMap.entries
        .firstWhere((e) => e.value == widget.yearTitle, orElse: () => const MapEntry(1, ''))
        .key;
    if (_selectedYearIndex == 0) _selectedYearIndex = 1; // fallback
    
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final subjects = await _subjectService.getSubjects();
      final types = await _subjectService.getCourseTypes();

      if (mounted) {
        setState(() {
          _allSubjects = subjects;
          _courseTypes = types;
          _isLoading = false;
          
          // Initial default selection
          final validTypes = types.where((t) => (t['academic_year']?['name'] ?? '') == _currentYearTitle).toList();
          if (validTypes.isNotEmpty) {
             _selectedTypeId = validTypes.first['id'];
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Filter Logic
  List<dynamic> get _displayedSubjects {
    // 1. Filter by Year
    final yearFiltered = _allSubjects.where((s) {
       final subjectYear = s['academic_year']?['name'] ?? '';
       // Simplify matching: The subject's academic year name must match current year
       return subjectYear == _currentYearTitle;
    }).toList();

    // 2. Filter by Type
    // If _selectedTypeId is null, show all? No, user wants first selected by default.
    // But if list is empty?
    if (_selectedTypeId == null) return yearFiltered;
    return yearFiltered.where((s) => s['course_type_id'] == _selectedTypeId).toList();
  }

  // Filter Course Types by Year
  List<dynamic> get _filteredCourseTypes {
    return _courseTypes.where((type) {
      final typeYear = type['academic_year']?['name'];
      // If type has no year assigned, maybe show it? Or filtered out? 
      // Assumption: All types must have year now.
      return typeYear == _currentYearTitle;
    }).toList();
  }

  void _onYearSelected(int year) {
    setState(() {
      _selectedYearIndex = year;
      _currentYearTitle = _yearToTitleMap[year] ?? 'السنة $year';
      
      // Reset selected type to first available in new year
      final typesForYear = _filteredCourseTypes; // Getter uses new _currentYearTitle? No, getter evaluates on access.
      // Wait, inside setState, getters might use old state if not careful? 
      // _currentYearTitle is updated.
      // We need to re-evaluate filtering to pick default.
      
      // Let's do it after this frame or right here explicitly
      final validTypes = _courseTypes.where((t) => (t['academic_year']?['name'] ?? '') == _currentYearTitle).toList();
      if (validTypes.isNotEmpty) {
        _selectedTypeId = validTypes.first['id'];
      } else {
        _selectedTypeId = null; 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayTypes = _filteredCourseTypes;

    // Ensure we have a selection if possible (double check)
    if (_selectedTypeId == null && displayTypes.isNotEmpty) {
       // Loop safety? ideally handled in _onYearSelected or fetch
       // But trigger a microtask or just set it? 
       // Better not set state during build.
       // It's handled in logic below: if selected is null, we might need to highlight first?
       // But _selectedTypeId drives the subject filter.
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        toolbarHeight: 80, 
        title: SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: widget.totalYears,
            itemBuilder: (context, index) {
              final yearNum = index + 1;
              final isSelected = _selectedYearIndex == yearNum;
              
              return GestureDetector(
                onTap: () => _onYearSelected(yearNum),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  padding: EdgeInsets.symmetric(horizontal: isSelected ? 24 : 0),
                  constraints: const BoxConstraints(minWidth: 50, minHeight: 50),
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: isSelected ? null : Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: isSelected 
                      ? Text(
                          _yearToTitleMap[yearNum] ?? 'السنة $yearNum',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2196F3),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        )
                      : Text(
                          '$yearNum',
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Course Types Filters
                if (displayTypes.isNotEmpty)
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: displayTypes.map((type) {
                        final isSelected = _selectedTypeId == type['id'];
                        
                        // Standard Colors: Selected = Gold, Unselected = Grey
                        final bgColor = isSelected ? const Color(0xFFCDC346) : Colors.grey[200];
                        final textColor = isSelected ? Colors.black : Colors.black87; 

                        return GestureDetector(
                          onTap: () {
                             // User wants to force selection? "first one should always be selected" implies toggling off might not be allowed?
                             // Or just simplified switching.
                             setState(() {
                               _selectedTypeId = type['id'];
                             });
                          },
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 80),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected ? Border.all(color: Colors.black12, width: 1) : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              type['name'],
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),


                // Subjects List
                Expanded(
                  child: _displayedSubjects.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد مواد في هذا التصنيف',
                            style: GoogleFonts.cairo(color: Colors.grey),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Mandatory Subjects
                              _buildGrid(_displayedSubjects
                                  .where((s) => s['is_optional'] != true && s['is_optional'] != 1)
                                  .toList()),

                              // Optional Subjects Section
                              if (_displayedSubjects
                                  .any((s) => s['is_optional'] == true || s['is_optional'] == 1)) ...[
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8D6E63), // Brownish color from screenshot
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'المواد الإختيارية',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildGrid(_displayedSubjects
                                    .where((s) => s['is_optional'] == true || s['is_optional'] == 1)
                                    .toList()),
                              ],
                              
                              const SizedBox(height: 40), // Bottom padding
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildGrid(List<dynamic> subjects) {
    if (subjects.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        return _buildSubjectCard(context, subjects[index]);
      },
    );
  }

  Widget _buildSubjectCard(BuildContext context, dynamic subject) {
    final name = subject['name'] ?? 'Unknown';
    final code = subject['code'] ?? '---';
    final courseDetails = subject['course_type'] ?? {};
    
    // Parse color for header/border from course type
    Color typeColor = Colors.blue; 
    if (courseDetails['color'] != null) {
       try {
         typeColor = Color(int.parse(courseDetails['color'].replaceAll('#', '0xFF')));
       } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header / ID ?
          // Matching screenshot top labels "1" or specific headers? 
          // Screenshot has title in blue.
          const SizedBox(height: 12),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
                height: 1.2,
              ),
            ),
          ),
          
          // Meta Data
          Column(
            children: [
               Text(
                'رمز المادة: $code',
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
               const SizedBox(height: 2),
               Text(
                'نظام الامتحان: أتمتة', 
                 style: GoogleFonts.cairo(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // Icons Row
          Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
                // Eye / Views
                const Icon(Icons.remove_red_eye_outlined, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text('999', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                
                const SizedBox(width: 12),
                
                // Book / Lessons
                const Icon(Icons.menu_book, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text('99', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
             ],
          ),

          // Action Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                 Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubjectDetailScreen(
                        subjectId: subject['id'],
                        title: subject['name'] ?? 'تفاصيل المادة',
                      ),
                    ),
                  );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC0CA33), // Olive/Gold color from screenshot
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text(
                'عرض',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
