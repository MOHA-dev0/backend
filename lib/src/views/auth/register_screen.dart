import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/device_service.dart';
import '../../core/utils/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  final String phone;
  final String otp;
  const RegisterScreen({super.key, required this.phone, required this.otp});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _addressController = TextEditingController();

  // Selected Values
  String? _selectedTitle;
  String? _selectedGender;
  String? _selectedGovernorate;
  String? _selectedRegistrationUniversityId; // For Registration
  String? _selectedYearId;

  // State
  bool _isLoading = false;
  bool _isInit = true;
  bool _hasError = false;
  Map<String, dynamic> _lookups = {};

  final AuthService _authService = AuthService();
  final DeviceService _deviceService = DeviceService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadLookups();
      _isInit = false;
    }
  }

  Future<void> _loadLookups() async {
    setState(() {
      _hasError = false;
    });
    try {
      final data = await _authService.getRegisterLookups();
      setState(() {
        _lookups = data;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connection Error: $e')));
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final deviceUuid = await _deviceService.getDeviceId();
      final deviceName = await _deviceService.getDeviceName();

      final newUser = await _authService.register({
        'phone': widget.phone,
        'otp': widget.otp,
        'first_name': _firstNameController.text,
        'second_name': _secondNameController.text,
        'registration_university_id': _selectedRegistrationUniversityId,
        'academic_year_id': _selectedYearId,
        'title': _selectedTitle,
        'gender': _selectedGender,
        'governorate': _selectedGovernorate,
        'address': _addressController.text,
        'device_uuid': deviceUuid,
        'device_name': deviceName,
      });

      if (mounted) {
        // Context is still valid here
        context.read<UserProvider>().setUser(newUser);
        Navigator.pushReplacementNamed(context, '/university');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'بيانات الملف الشخصي',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'فشل تحميل البيانات',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadLookups,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_lookups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Row 1: First Name & Second Name
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_firstNameController, 'الاسم الأول'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(_secondNameController, 'الاسم الثاني'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // University Dropdown
                  // Registration University Dropdown (NEW)
                  _buildDropdown<String>(
                    hint: 'جامعة التسجيل',
                    value: _selectedRegistrationUniversityId,
                    items: (_lookups['registration_universities'] as List? ?? [])
                        .map<DropdownMenuItem<String>>((t) {
                          final name = t['name'] as String;
                          final id = t['id'].toString();
                          return DropdownMenuItem(
                            value: id,
                            child: Center(child: Text(name)),
                          );
                        })
                        .toList(),
                    onChanged: (val) => setState(() => _selectedRegistrationUniversityId = val),
                  ),
                  // Registration University Dropdown (NEW)
                  const SizedBox(height: 30),

                   // Year Dropdown
                  _buildDropdown<String>(
                    hint: 'أختر السنة',
                    value: _selectedYearId, // Need to add this variable
                    items: (_lookups['academic_years'] as List? ?? [])
                        .map<DropdownMenuItem<String>>((t) {
                          final name = t['name'] as String;
                          final id = t['id'].toString();
                          return DropdownMenuItem(
                            value: id,
                            child: Center(child: Text(name)),
                          );
                        })
                        .toList(),
                    onChanged: (val) => setState(() => _selectedYearId = val),
                  ),
                  const SizedBox(height: 30),

                  // Row 2: Gender (Right) & Title (Left) - Swapped
                  Row(
                    children: [
                      // Gender (Now First/Right in RTL)
                      Expanded(
                        child: _buildDropdown<String>(
                          hint: 'حدد الجنس',
                          value: _selectedGender,
                          items: (_lookups['genders'] as List? ?? [])
                              .map<DropdownMenuItem<String>>((t) {
                                final name = t['name'] as String;
                                return DropdownMenuItem(
                                  value: name,
                                  child: Center(child: Text(name)),
                                );
                              })
                              .toList(),
                          onChanged: (val) => setState(() {
                            _selectedGender = val;
                            _selectedTitle = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                       // Title (Now Second/Left in RTL)
                      Expanded(
                        child: _buildDropdown<String>(
                          hint: 'أختر اللقب',
                          value: _selectedTitle,
                          items: (_lookups['titles'] as List? ?? [])
                              .where((t) {
                                if (_selectedGender == null) return true;
                                final genderObj = t['gender'];
                                if (genderObj == null) return true; // Universal title
                                return genderObj['name'] == _selectedGender;
                              })
                              .map<DropdownMenuItem<String>>((t) {
                                final name = t['name'] as String;
                                return DropdownMenuItem(
                                  value: name,
                                  child: Center(child: Text(name)),
                                );
                              })
                              .toList(),
                          onChanged: (val) => setState(() => _selectedTitle = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Governorate
                  _buildDropdown(
                    hint: 'أختر المحافظة',
                    value: _selectedGovernorate,
                    items: (_lookups['governorates'] as List? ?? [])
                        .map<DropdownMenuItem<String>>((t) {
                          final name = t['name'] as String;
                          return DropdownMenuItem(
                            value: name,
                            child: Center(child: Text(name)),
                          );
                        })
                        .toList(),
                    onChanged: (val) => setState(() => _selectedGovernorate = val),
                  ),
                  const SizedBox(height: 30),

                  // Address
                  _buildTextField(_addressController, 'أدخل عنوانك'),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        
        // Save Button (Pinned to Bottom)
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: AppColors.background, // Match background
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
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
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'حفظ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ), // Cyan/Blue border
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textAlign: TextAlign.center, // Center text per design
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: (v) => v!.isEmpty ? '' : null, // Minimal validation UI
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Center(
            child: Text(
              hint,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.border),
        ),
      ),
    );
  }
}
