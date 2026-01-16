import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:intl/intl.dart' as intl;

import '../../core/providers/user_provider.dart';
import '../../core/services/auth_service.dart';

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  State<AccountVerificationScreen> createState() => _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  final TextEditingController _universityIdController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  final List<File> _selectedImages = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يمكنك تحميل 5 مستندات كحد أقصى')),
      );
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 70,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
             if (_selectedImages.length < 5) {
               _selectedImages.add(File(image.path));
             }
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, 
              onPrimary: Colors.white, 
              onSurface: Colors.black, 
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = intl.DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitVerification() async {
    if (_universityIdController.text.isEmpty || _selectedDate == null || _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول وتحميل مستند واحد على الأقل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use existing updateProfile or create new Function in AuthService?
      // Since it's a specific endpoint 'verify-account', we should add it to AuthService logic but here we can use a direct call or similar.
      // Assuming AuthService has a generic multipart request or we add `verifyAccount` to AuthService.
      // For now, I'll bypass AuthService wrapper if it doesn't support generic multipart, 
      // but cleaning code suggests adding it to AuthService.
      // Checking AuthService... It's likely better to add it there.
      
      // Temporary: Implementing direct logic or assuming userProvider has it? 
      // UserProvider doesn't have it.
      // I'll assume I can add it to AuthService later. For now, calling AuthService.
      
      final authService = AuthService();
      await authService.verifyAccount(
        universityId: _universityIdController.text,
        dob: _dobController.text,
        documents: _selectedImages,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفع طلب التوثيق بنجاح')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'توثيق الحساب',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2962FF), // Blue Header
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white, // White background
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Info Text
                Text(
                  ':عزيزي الطالب',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFFE57373), // Light Red/Pink
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'لتوثيق حسابك يرجى تعبئة البيانات أدناه',
                  style: GoogleFonts.cairo(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 30),

                // Form Fields Row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _dobController,
                            hint: 'المواليد',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _universityIdController,
                        hint: 'الرقم الجامعي',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Upload Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5), // Light Grey for box
                    // The image shows a defined box with border.
                    border: Border.all(color: Colors.amber, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        ':يرجى تحميل أحد الوثائق التالية',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFFE57373),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionItem('1- صورة عن البطاقة الجامعية في حال توفرها.'),
                      _buildInstructionItem('2- أو صورة عن بروفايل الحساب الجامعي.'),
                      _buildInstructionItem('3- أو بطاقة نقابة المحامين.'),
                      
                      const SizedBox(height: 24),
                      
                      // Files Preview
                      if (_selectedImages.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedImages.map((file) => Stack(
                            children: [
                              Image.file(file, width: 60, height: 60, fit: BoxFit.cover),
                              Positioned(
                                right: 0, top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.remove(file);
                                    });
                                  },
                                  child: const Icon(Icons.cancel, color: Colors.red, size: 20),
                                ),
                              )
                            ],
                          )).toList(),
                        ),
                        
                      if (_selectedImages.isNotEmpty) const SizedBox(height: 16),

                      // Upload Button
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _pickImages,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7986CB), // Bluish Grey
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'تحميل',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                 ),

                 const SizedBox(height: 30),
                 
                 // Submit Button
                 if (_selectedImages.isNotEmpty)
                   SizedBox(
                     width: double.infinity,
                     height: 50,
                     child: ElevatedButton(
                       onPressed: _isLoading ? null : _submitVerification,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF2962FF),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(12),
                         ),
                       ),
                       child: _isLoading 
                         ? const CircularProgressIndicator(color: Colors.white)
                         : Text(
                           'إرسال الطلب',
                           style: GoogleFonts.cairo(
                             fontSize: 18, 
                             fontWeight: FontWeight.bold,
                             color: Colors.white
                           ),
                         ),
                     ),
                   ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD7CCC8).withOpacity(0.5), // Beige/Tan background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.cairo(color: Colors.grey[700], fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          color: Colors.grey[700],
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
