import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/complaint_service.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ComplaintService _complaintService = ComplaintService();
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _submitComplaint() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء كتابة تفاصيل الشكوى أو المقترح')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _complaintService.submitComplaint(
        message: _messageController.text.trim(),
        imageFile: _selectedImage,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'تم الإرسال',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Text(
              'تم استلام طلبك بنجاح وسيتم مراجعته قريباً.',
              style: GoogleFonts.cairo(),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Text(
                  'حسناً',
                  style: GoogleFonts.cairo(color: Colors.blue),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ: ${e.toString().replaceAll('Exception:', '')}',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'تقديم شكوى أو مقترح',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'معلومات مقدم الطلب',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            _buildReadOnlyField(
              label: 'الاسم',
              value: user?.name ?? '',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),

            _buildReadOnlyField(
              label: 'رقم الهاتف',
              value: user?.phone ?? '',
              icon: Icons.phone_android,
            ),

            const SizedBox(height: 32),

            Text(
              'تفاصيل الطلب',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _messageController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'اكتب تفاصيل الشكوى أو المقترح هنا...',
                hintStyle: GoogleFonts.cairo(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: GoogleFonts.cairo(),
            ),

            const SizedBox(height: 20),

            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[50],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: _selectedImage != null
                          ? Colors.green
                          : Colors.grey,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedImage != null
                            ? 'تم إرفاق صورة (اضغط للتغيير)'
                            : 'إرفاق صورة توضيحية (اختياري)',
                        style: GoogleFonts.cairo(
                          color: _selectedImage != null
                              ? Colors.green
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_selectedImage != null)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),

            if (_selectedImage != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.network(
                        _selectedImage!.path,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(_selectedImage!.path),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            ],

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _isLoading ? null : _submitComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E6FF2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'إرسال الطلب',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[500]),
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
