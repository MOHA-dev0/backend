import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/device_service.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import 'register_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone;
  const OtpVerifyScreen({super.key, required this.phone});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final DeviceService _deviceService = DeviceService();

  Future<void> _verify() async {
    if (_otpController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final deviceUuid = await _deviceService.getDeviceId();
      final user = await _authService.verifyOtp(widget.phone, _otpController.text, deviceUuid);
      
      if (mounted) {
        // Update Provider
        context.read<UserProvider>().setUser(user);

        // Check if profile is complete (University selected)
        if (user.universityId == null) {
          Navigator.pushNamedAndRemoveUntil(context, '/university', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString();
        
        // If user not found (404) OR explicitly "User not found"
        if (message.contains('404') || message.contains('User not found')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterScreen(
                phone: widget.phone,
                otp: _otpController.text,
              ),
            ),
          );
        } else {
          // Other error
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $message')));
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
     const backgroundColor = Color(0xFFEBFDFD); 
     const primaryBlue = Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('تأكيد الرمز', style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: primaryBlue, 
        foregroundColor: Colors.white, 
        centerTitle: true
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              'أدخل الرمز المرسل إلى ${widget.phone}', 
              style: const TextStyle(fontSize: 16),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '--- ---',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryBlue)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('تأكيد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
