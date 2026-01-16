import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../core/providers/config_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/device_service.dart';
import '../../core/providers/user_provider.dart';
import '../home/home_screen.dart';
import 'otp_verify_screen.dart';
import 'register_screen.dart';
import '../shared/modern_loader.dart';
import '../../core/utils/string_extensions.dart';
import '../../core/utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;

  final AuthService _authService = AuthService();
  final DeviceService _deviceService = DeviceService();

  List<dynamic> _countries = [];
  Map<String, dynamic>? _selectedCountry;

  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    if (mounted) setState(() => _hasError = false);
    try {
      final data = await _authService.getRegisterLookups();
      if (mounted) {
        setState(() {
          _countries = data['countries'] ?? [];
          if (_countries.isNotEmpty) {
            // Default to Syria or first
            _selectedCountry = _countries.firstWhere(
              (c) => c['name'].toString().contains('سوريا'),
              orElse: () => _countries.first,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching countries: $e');
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final rawPhone = _phoneController.text.trim().toEnglishDigits();
    if (rawPhone.isEmpty) {
      _showError('يرجى إدخال رقم الهاتف'); // "Please enter phone number"
      return;
    }

    if (_selectedCountry == null) {
      _showError('يرجى اختيار الدولة');
      return;
    }

    final code = _selectedCountry!['phone_code'];
    // Simple Formatting: Remove leading 0 if present, unless code is +963 and user types 09... -> standard is usually +9639...
    // Let's just prepend.
    final phone = '$code$rawPhone';

    setState(() => _isLoading = true);
    // ... rest of logic
    try {
      final deviceUuid = await _deviceService.getDeviceId();
      // 1. Check User Status
      final result = await _authService.checkStatus(phone, deviceUuid);

      if (!mounted) return;

      if (result['status'] == 'DEVICE_MISMATCH') {
        // Security Feature: Device Lock
        _showError(result['message'] ?? 'Account locked to another device.');
        return;
      }

      await _authService.sendOtp(phone);

      // 3. Show OTP Bottom Sheet
      if (mounted) {
        _showOtpBottomSheet(context, phone);
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showOtpBottomSheet(BuildContext context, String phone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _OtpBottomSheet(phone: phone, authService: _authService),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Unified Blueish Bg
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 0,
              color: AppColors.background, // Light Cyan/Blueish Card Bg
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ), // Square-ish as per image, or slightly rounded is better? Image looks clean.
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 40.0,
                  horizontal: 24.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset('assets/images/logo.png', height: 80),
                    const SizedBox(height: 20),

                    // Title "تسجيل الدخول" (Red)
                    const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red, // Red Title
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'سيتم إرسال رمز التحقيق عبر الواتساب',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Dropdown "الجمهورية العربية السورية"
                    // Static for now as requested, or just a decorated container that looks like it
                    // Dropdown "الجمهورية العربية السورية"
                    // Dropdown "الجمهورية العربية السورية"
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      child: _hasError
                          ? Center(
                              child: TextButton.icon(
                                onPressed: _fetchCountries,
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'إعادة المحاولة',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            )
                          : _countries.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: ModernLoader(
                                  color: AppColors.primary,
                                  size: 30,
                                ), // Use Modern Loader
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<Map<String, dynamic>>(
                                // ... (Dropdown content remains same)
                                isExpanded: true,
                                value: _selectedCountry,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.blue[300],
                                ),
                                items: _countries.map((country) {
                                  return DropdownMenuItem<Map<String, dynamic>>(
                                    value: country,
                                    child: Text(
                                      country['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() => _selectedCountry = val);
                                },
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Phone Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          hintText: 'أدخل رقم الواتس آب',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth:
                                      2.5, // Thinner stroke looks sharper
                                ),
                              )
                            : const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBottomSheet extends StatefulWidget {
  final String phone;
  final AuthService authService;
  const _OtpBottomSheet({required this.phone, required this.authService});

  @override
  State<_OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<_OtpBottomSheet> {
  final _otpController = TextEditingController();
  final _deviceService = DeviceService();
  bool _isLoading = false;

  Future<void> _verify() async {
    if (_otpController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final otp = _otpController.text.toEnglishDigits();

    try {
      final deviceUuid = await _deviceService.getDeviceId();
      final user = await widget.authService.verifyOtp(
        widget.phone,
        otp,
        deviceUuid,
      );

      if (mounted) {
        // Update Provider
        context.read<UserProvider>().setUser(user);

        Navigator.pop(context); // Close sheet

        // Check if user has selected a university
        // Check Status
        // Check Status
        if (user.status == 'banned' || user.status == 'restricted') {
          Navigator.of(context).pop(); // Close sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حظر حسابك. يرجى التواصل مع الإدارة.'),
              backgroundColor: Colors.red,
            ),
          );
          // Ensure logged out
          context.read<UserProvider>().logout();
          return;
        } else if (user.universityId == null) {
          // New User or hasn't selected uni yet
          Navigator.pushReplacementNamed(context, '/university');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString();
        // New User -> Register
        if (message.contains('404') || message.contains('User not found')) {
          Navigator.pop(context); // Close sheet
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RegisterScreen(phone: widget.phone, otp: otp),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ: $message')));
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'تأكيد الرمز',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'أدخل الرمز المرسل إلى ${widget.phone}',
            style: TextStyle(color: Colors.grey[600]),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 30),

          Directionality(
            textDirection: TextDirection.ltr, // OTP is LTR always
            child: Pinput(
              controller: _otpController,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              onCompleted: (pin) => _verify(),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const ModernLoader(color: Colors.white, size: 24)
                  : const Text(
                      'تأكيد',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
