import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

class GradeCalculatorScreen extends StatefulWidget {
  const GradeCalculatorScreen({super.key});

  @override
  State<GradeCalculatorScreen> createState() => _GradeCalculatorScreenState();
}

class _GradeCalculatorScreenState extends State<GradeCalculatorScreen> {
  late ConfettiController _confettiController;

  // Controllers
  final TextEditingController _assignmentController = TextEditingController();
  final TextEditingController _examController = TextEditingController();

  // State
  int? _assignmentResult; // C2
  int? _examResult; // C3
  int? _finalScore; // B4
  String _evaluationMessage = '';
  Color _evaluationColor = Colors.transparent;
  Color _assignmentBoxColor = const Color(0xFFEFF6FF); // Blue-50 equivalent
  Color _examBoxColor = const Color(0xFFEFF6FF);

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _assignmentController.addListener(_calculate);
    _examController.addListener(_calculate);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _assignmentController.dispose();
    _examController.dispose();
    super.dispose();
  }

  String _normalizeNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    return input;
  }

  void _calculate() {
    // Parse Inputs (Normalizing Arabic Numerals)
    double? b2 = double.tryParse(_normalizeNumber(_assignmentController.text));
    double? b3 = double.tryParse(_normalizeNumber(_examController.text));

    // Clamp values (0-100)
    if (b2 != null) {
      if (b2 > 100) {
        b2 = 100;
        _assignmentController.text = '100';
        _assignmentController.selection = TextSelection.fromPosition(const TextPosition(offset: 3));
      }
      if (b2 < 0) b2 = 0;
    }
    if (b3 != null) {
      if (b3 > 100) {
        b3 = 100;
        _examController.text = '100';
         _examController.selection = TextSelection.fromPosition(const TextPosition(offset: 3));
      }
      if (b3 < 0) b3 = 0;
    }

    // Calculate Weighted Scores
    int c2 = (b2 != null) ? (b2 * 0.2).ceil() : 0;
    int c3 = (b3 != null) ? (b3 * 0.8).ceil() : 0;

    // Update Scores State
    setState(() {
      _assignmentResult = (b2 != null) ? c2 : null;
      _examResult = (b3 != null) ? c3 : null;
      _finalScore = (b2 != null || b3 != null) ? (c2 + c3) : null;
    });

    // Update Colors
    _updateColors(c2, c3);

    // Update Evaluation Message
    _updateEvaluation(b2, b3, c2, c3, c2 + c3);
  }

  void _updateColors(int c2, int c3) {
    // Assignment Box
    if (_assignmentResult == null) {
      _assignmentBoxColor = const Color(0xFFEFF6FF); // blue-50
    } else if (_assignmentResult! >= 8) {
      _assignmentBoxColor = const Color(0xFFDCFCE7); // green-100
    } else {
      _assignmentBoxColor = const Color(0xFFFEE2E2); // red-100
    }

    // Exam Box
    if (_examResult == null) {
      _examBoxColor = const Color(0xFFEFF6FF); // blue-50
    } else if (_examResult! >= 32) {
      _examBoxColor = const Color(0xFFDCFCE7); // green-100
    } else {
      _examBoxColor = const Color(0xFFFEE2E2); // red-100
    }
  }

  void _updateEvaluation(double? cleanB2, double? cleanB3, int c2, int c3, int b4) {
    String message = "";
    Color color = Colors.transparent;
    bool success = false;

    if (cleanB2 == null && cleanB3 == null) {
      message = "";
      color = Colors.transparent;
    } else {
      if (cleanB2 != null && cleanB2 <= 39) {
        message = "لا يستطيع الطالب أن يتقدم للامتحان";
        color = const Color(0xFFFEE2E2); // red-100
      } else if (cleanB2 != null && cleanB2 >= 40 && cleanB3 == null) {
        int neededForExam = math.max(40, ((49 - c2) / 0.8 + 0.001).ceil());
        message = 'تحتاج ($neededForExam) درجة كحد أدنى في الامتحان للنجاح';
        color = const Color(0xFFFEF9C3); // yellow-100
      } else if (cleanB3 != null && cleanB3 >= 40 && cleanB2 == null) {
        int neededForAssignment = math.max(40, ((49 - c3) / 0.2 + 0.001).ceil());
        message = 'تحتاج ($neededForAssignment) درجة كحد أدنى في الوظيفة للنجاح';
        color = const Color(0xFFFEF9C3); // yellow-100
      } else if (cleanB2 != null && cleanB2 >= 40 && cleanB3 != null && cleanB3 >= 40 && b4 >= 50) {
        message = "مبارك، ناجح";
        color = const Color(0xFFDCFCE7); // green-100
        success = true;
      } else if (cleanB2 != null && cleanB2 >= 40 && cleanB3 != null && cleanB3 >= 38 && b4 >= 48) {
        message = "تحتاج مساعدة من أجل النجاح";
        color = const Color(0xFFFFEDD5); // orange-100
      } else if (cleanB3 != null && cleanB3 <= 37) {
        message = "راسب";
        color = const Color(0xFFFEE2E2); // red-100
      } else if (cleanB2 != null && cleanB3 != null && b4 <= 47) {
        message = "راسب";
        color = const Color(0xFFFEE2E2); // red-100
      }
    }

    setState(() {
      _evaluationMessage = message;
      _evaluationColor = color;
    });

    if (success) {
      _confettiController.play();
    } else {
      _confettiController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB), // bg-gray-200
      body: Stack(
        children: [
          // Main Content
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity, 
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB), // mobile screen bg
                borderRadius: BorderRadius.circular(0), // Full screen on mobile
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'حاسبة علاماتي',
                        style: GoogleFonts.tajawal(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),

                    // Inputs
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            // Assignment Input
                            _buildInputRow(
                              controller: _assignmentController,
                              placeholder: 'أدخل علامة الوظيفة',
                              result: _assignmentResult,
                              resultColor: _assignmentBoxColor,
                              borderColor: Colors.blue,
                            ),
                            const SizedBox(height: 24),
                            // Exam Input
                            _buildInputRow(
                              controller: _examController,
                              placeholder: 'أدخل علامة الامتحان',
                              result: _examResult,
                              resultColor: _examBoxColor,
                              borderColor: Colors.teal,
                            ),

                            const SizedBox(height: 24),
                            const Divider(thickness: 1, color: Color(0xFFE5E7EB)),
                            const SizedBox(height: 24),

                            // Final Score
                            Container(
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6), // gray-100
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _finalScore?.toString() ?? '',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.tajawal(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF111827),
                                  height: 1.0,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Evaluation Box
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _evaluationColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _evaluationMessage,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.tajawal(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Notes
                            Text(
                              'المواد المقالية يرجى إنتظار علامة السؤال المقالي حتى يكون تقييم المحصلة دقيق.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFDC2626), // red-600
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'يساعد الطالب بـ (6) علامات إذا كانت المساعدة تؤدي إلى عدم استنفاده من الجامعة.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFDC2626), // red-600
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
            // Back Button
            Positioned(
             top: 50,
             right: 20,
             child: IconButton(
               icon: const Icon(Icons.arrow_back, color: Colors.black87), // RTL Back (Points Right in RTL)
               onPressed: () => Navigator.pop(context),
             ),
           ),

          // Confetti Effect
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, // radiate out
              shouldLoop: false, // one shot
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ], 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow({
    required TextEditingController controller,
    required String placeholder,
    required int? result,
    required Color resultColor,
    required Color borderColor,
  }) {
    return Row(
      children: [
        // Input Field
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: GoogleFonts.tajawal(fontSize: 16, color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor, width: 2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Result Box
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 90,
          height: 52, // Match input height roughly
          decoration: BoxDecoration(
            color: resultColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              result?.toString() ?? '',
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
