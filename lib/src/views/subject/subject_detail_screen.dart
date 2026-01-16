import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/config_provider.dart';
import '../../core/services/subject_service.dart';
import '../../core/models/lesson_model.dart';
import 'lesson_detail_screen.dart';
import 'unit_content_screen.dart';
import 'audio_player_screen.dart';
import 'unit_detail_screen.dart';

class SubjectDetailScreen extends StatefulWidget {
  final int subjectId;
  final String title;

  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
    required this.title,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen>
    with SingleTickerProviderStateMixin {
  final _subjectService = SubjectService();
  Map<String, dynamic>? _subjectData;
  bool _isLoading = true;
  late TabController _tabController;

  // Subscription Selection State
  bool _buyUnits = false;
  bool _buyQuestions = false;
  bool _buyAudio = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    try {
      final data = await _subjectService.getSubjectDetails(widget.subjectId);
      if (mounted) {
        setState(() {
          _subjectData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint(e.toString());
    }
  }

  void _showSubscriptionModal() {
    if (_subjectData == null) return;

    // Reset selection
    _buyUnits = false;
    _buyQuestions = false;
    _buyAudio = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final config = context.read<ConfigProvider>().config;

          double priceUnit =
              double.tryParse(_subjectData!['price_unit']?.toString() ?? '0') ??
              0;
          double priceQuestion =
              double.tryParse(
                _subjectData!['price_question']?.toString() ?? '0',
              ) ??
              0;
          double priceAudio =
              double.tryParse(
                _subjectData!['price_audio']?.toString() ?? '0',
              ) ??
              0;

          // Calculate Total
          int selectedCount = 0;
          double subtotal = 0;
          if (_buyUnits) {
            selectedCount++;
            subtotal += priceUnit;
          }
          if (_buyQuestions) {
            selectedCount++;
            subtotal += priceQuestion;
          }
          if (_buyAudio) {
            selectedCount++;
            subtotal += priceAudio;
          }

          double discountPercent = 0;
          if (selectedCount == 2)
            discountPercent = config.discount2Items.toDouble();
          if (selectedCount == 3)
            discountPercent = config.discount3Items.toDouble();

          double discountAmount = subtotal * (discountPercent / 100);
          double finalTotal = subtotal - discountAmount;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اشتراك في المقرر',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Options
                if (priceUnit > 0)
                  _buildOptionTile(
                    'القررات الدراسية',
                    priceUnit,
                    _buyUnits,
                    (val) => setModalState(() => _buyUnits = val ?? false),
                  ),
                if (priceQuestion > 0)
                  _buildOptionTile(
                    'بنك الأسئلة',
                    priceQuestion,
                    _buyQuestions,
                    (val) => setModalState(() => _buyQuestions = val ?? false),
                  ),
                if (priceAudio > 0)
                  _buildOptionTile(
                    'المكتبة الصوتية',
                    priceAudio,
                    _buyAudio,
                    (val) => setModalState(() => _buyAudio = val ?? false),
                  ),

                if (priceUnit == 0 && priceQuestion == 0 && priceAudio == 0)
                  const Text(
                    'لا توجد باقات متاحة حالياً',
                    style: TextStyle(color: Colors.grey),
                  ),

                const Divider(height: 32),

                // Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المجموع', style: GoogleFonts.cairo(fontSize: 16)),
                    Text(
                      '${subtotal.toStringAsFixed(0)} ل.س',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        decoration: discountAmount > 0
                            ? TextDecoration.lineThrough
                            : null,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (discountAmount > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'خصم الباقة ($selectedCount)',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '-${discountAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الإجمالي',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${finalTotal.toStringAsFixed(0)} ل.س',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1877F2),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: selectedCount > 0
                        ? () async {
                            // Store the navigator before popping modal
                            final navigator = Navigator.of(context);
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );

                            // Close the modal first
                            navigator.pop();

                            // Use a global key or BuildContext from the main screen
                            // For now, we'll show a simple loading overlay using the screen's context

                            try {
                              // Call API directly without showing dialog (to avoid context issues)
                              final result = await _subjectService
                                  .purchaseSubject(
                                    subjectId: widget.subjectId,
                                    buyUnits: _buyUnits,
                                    buyQuestions: _buyQuestions,
                                    buyAudio: _buyAudio,
                                  );

                              if (result['success'] == true) {
                                // Update user balance
                                if (mounted && result['balance'] != null) {
                                  context.read<UserProvider>().updateBalance(
                                    (result['balance'] as num).toDouble(),
                                  );
                                }

                                // Refresh subject data
                                await _fetchDetails();

                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result['message'] ??
                                            'تمت عملية الشراء بنجاح',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result['message'] ?? 'فشلت العملية',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              debugPrint('Purchase Error: $e');
                              if (mounted) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'حدث خطأ، يرجى المحاولة لاحقاً',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC0CA33),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إتمام الشراء',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionTile(
    String title,
    double price,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      secondary: Text(
        '${price.toStringAsFixed(0)} ل.س',
        style: GoogleFonts.cairo(color: Colors.blue),
      ),
      activeColor: const Color(0xFFC0CA33),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_subjectData == null)
      return const Scaffold(body: Center(child: Text('Error loading data')));

    final units = _subjectData!['units'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1877F2), // Blue Header
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          // Subscribe Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ElevatedButton(
              onPressed: _showSubscriptionModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC0CA33), // Goldish
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'اشتراك',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFFC0CA33),
          indicatorWeight: 4,
          labelStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'الوحدات الدراسية'),
            Tab(text: 'الأسئلة التدريبية'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Units List
          _buildUnitsList(units),

          // Questions List (Placeholder)
          Center(
            child: Text(
              'بنك الأسئلة قريباً',
              style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitsList(List<dynamic> units) {
    if (units.isEmpty) {
      return Center(
        child: Text(
          'لا توجد وحدات متاحة',
          style: GoogleFonts.cairo(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85, // Adjust for card height
      ),
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unit = units[index];
        bool isFree = unit['is_free'] == true || unit['is_free'] == 1;

        // Check if user has purchased units access for this subject
        bool hasUnitsAccess =
            _subjectData?['user_access']?['has_units'] == true;

        // Unit is unlocked if: it's free OR user has purchased units access
        bool isLocked = !isFree && !hasUnitsAccess;

        return GestureDetector(
          onTap: () {
            if (isLocked) {
              _showSubscriptionModal();
            } else {
              // Navigate to unit detail
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UnitDetailScreen(unit: unit)),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC0CA33),
                width: 1.5,
              ), // Golden border
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    unit['title'] ?? 'Unit ${index + 1}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF1565C0),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Lock Status
                Icon(
                  isLocked ? Icons.lock : Icons.lock_open,
                  color: isLocked ? Colors.red : Colors.green,
                  size: 24,
                ),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Views
                    const Icon(
                      Icons.remove_red_eye,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '999',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Pages
                    const Icon(Icons.menu_book, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${unit['page_count'] ?? 0}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Audio Icon (if audio exists)
                    if (unit['audio_url'] != null &&
                        unit['audio_url'].toString().isNotEmpty) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          // Check audio access
                          bool hasAudioAccess =
                              _subjectData?['user_access']?['has_audio'] ==
                              true;
                          bool isFreeUnit =
                              unit['is_free'] == true || unit['is_free'] == 1;

                          if (hasAudioAccess || isFreeUnit) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AudioPlayerScreen(
                                  unitId: unit['id'] ?? 0,
                                  unitTitle: unit['title'] ?? 'الوحدة',
                                  audioUrl: unit['audio_url'],
                                  audioTitle: unit['audio_title'],
                                  audioDuration: unit['audio_duration'],
                                ),
                              ),
                            );
                          } else {
                            _showSubscriptionModal();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC0CA33).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.headphones,
                            size: 18,
                            color: Color(0xFFC0CA33),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: (50 * index).ms).scale(),
        );
      },
    );
  }
}
