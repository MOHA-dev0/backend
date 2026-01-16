import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:share_plus/share_plus.dart';
import '../../core/providers/config_provider.dart';
import '../../core/providers/user_provider.dart';
import '../settings/legal_screen.dart';
import 'contact_us_screen.dart';
import '../onboarding/university_selection_screen.dart';
import 'complaint_screen.dart';
import 'account_verification_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showRechargeDialog(BuildContext context, double currentBalance) async {
    final TextEditingController _codeController = TextEditingController();
    bool _isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   // Close Button
                   Align(
                     alignment: Alignment.centerLeft,
                     child: GestureDetector(
                       onTap: () => Navigator.pop(context),
                       child: const Icon(Icons.close, size: 24, color: Colors.black),
                     ),
                   ),
                   const SizedBox(height: 8),
                   
                   Text(
                     'الرصيد الحالي',
                     style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
                   ),
                   Text(
                     '${currentBalance.toStringAsFixed(2)} ل.س',
                     style: GoogleFonts.cairo(
                       fontWeight: FontWeight.bold, 
                       fontSize: 18, 
                       color: Colors.red
                     ),
                   ),
                   const SizedBox(height: 24),
                   
                   // Input Field
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16),
                     decoration: BoxDecoration(
                       color: const Color(0xFFFFF0F0), // Light red bg?
                       borderRadius: BorderRadius.circular(24),
                       border: Border.all(color: Colors.red.withOpacity(0.3)),
                     ),
                     child: TextField(
                       controller: _codeController,
                       textAlign: TextAlign.center,
                       decoration: InputDecoration(
                         border: InputBorder.none,
                         hintText: 'ادخل الكود هنا',
                         hintStyle: GoogleFonts.cairo(color: Colors.grey),
                       ),
                     ),
                   ),
                   const SizedBox(height: 24),
                   
                   // Submit Button
                   SizedBox(
                     width: 150,
                     child: ElevatedButton(
                       onPressed: _isLoading ? null : () async {
                         if (_codeController.text.isEmpty) return;
                         setState(() => _isLoading = true);
                         final error = await context.read<UserProvider>().redeemCode(_codeController.text);
                         setState(() => _isLoading = false);
                         
                         if (error == null) {
                           Navigator.pop(context);
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('تمت التعبئة بنجاح', style: TextStyle(fontFamily: 'Cairo'))),
                           );
                         } else {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('خطأ: $error', style: const TextStyle(fontFamily: 'Cairo'))),
                           );
                         }
                       },
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFFC0CA33), // Goldish/Olive
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         padding: const EdgeInsets.symmetric(vertical: 10),
                       ),
                       child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                           'تعبئة',
                           style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                         ),
                     ),
                   )
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final config = context.watch<ConfigProvider>().config;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildProfileHeader(context, user),

            // Scrollable List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  const SizedBox(height: 10),

                  // Balance & TopUp
                  _buildActionItem(
                    context,
                    label:
                        'الرصيد ${user?.balance.toStringAsFixed(2) ?? "00.00"}',
                    icon: Icons.monetization_on_outlined,
                    actionLabel: 'تعبئة',
                    onAction: () {
                      _showRechargeDialog(context, user?.balance ?? 0);
                    },
                  ),

                  const SizedBox(height: 12),

                  // University & Switch
                  _buildActionItem(
                    context,
                    label: user?.universityName ?? 'الجامعة الافتراضية',
                    icon: Icons.school_outlined,
                    actionLabel: 'تبديل',
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const UniversitySelectionScreen(isEditing: true),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Trusted Account
                  _buildSimpleItem(
                    context,
                    label:
                        (user?.status == 'active' || user?.status == 'verified')
                        ? 'حساب موثوق'
                        : 'توثيق الحساب',
                    icon:
                        (user?.status == 'active' || user?.status == 'verified')
                        ? Icons.verified_user_outlined
                        : Icons.gpp_bad_outlined,
                    isVerified:
                        (user?.status == 'active' ||
                        user?.status == 'verified'),
                    textColor:
                        (user?.status == 'active' || user?.status == 'verified')
                        ? Colors.black87
                        : Colors.red,
                    iconColor:
                        (user?.status == 'active' || user?.status == 'verified')
                        ? Colors.blue
                        : Colors.red,
                    onTap: () {
                      if (user?.status != 'active' &&
                          user?.status != 'verified') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountVerificationScreen(),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // Dark Mode Toggle
                  _buildToggleItem(
                    context,
                    label: 'الوضع المظلم',
                    icon: Icons.nightlight_round,
                    value: false, // TODO: Link to ThemeProvider
                    onChanged: (val) {
                      // Toggle Theme
                    },
                  ),

                  const SizedBox(height: 12),

                  // Contact Info
                  _buildSimpleItem(
                    context,
                    label: 'معلومات التواصل',
                    icon: Icons.phone_in_talk_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactUsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Complaint/Suggestion
                  _buildSimpleItem(
                    context,
                    label: 'تقديم شكوى أو مقترح',
                    icon: Icons.edit_note_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ComplaintScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Share App
                  _buildSimpleItem(
                    context,
                    label: 'مشاركة التطبيق',
                    icon: Icons.share_outlined,
                    onTap: () {
                      Share.share('${config.shareText}\n${config.shareLink}');
                    },
                  ),

                  const SizedBox(height: 12),

                  // Privacy Policy
                  _buildSimpleItem(
                    context,
                    label: 'سياسة الخصوصية',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'سياسة الخصوصية',
                            type: LegalType.privacyPolicy,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Terms of Use
                  _buildSimpleItem(
                    context,
                    label: 'شروط الاستخدام',
                    icon: Icons.description_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'شروط الاستخدام',
                            type: LegalType.termsOfUse,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Logout
                  _buildSimpleItem(
                    context,
                    label: 'تسجيل الخروج',
                    icon: Icons.logout,
                    onTap: () async {
                      await userProvider.logout();
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom Nav Bar Placeholder if not handled by MainScreen
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFD700), // Gold (Left/Start)
            Color(0xFFFF5722), // Deep Orange/Red (Right/End)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Edit Icon + Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.blue),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      user?.name ?? 'اسم الطالب',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text on gradient
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, color: Colors.white, size: 20),
                  ],
                ),
                Text(
                  user?.academicYearName ?? 'السنة الدراسية',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user?.registrationUniversityName ??
                      user?.universityName ??
                      'جامعة دمشق',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return GestureDetector(
      onTap: onAction,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.blueGrey),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const Spacer(),

            // Action Button (Left side in RTL)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3C4), // Softer Gold background
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    actionLabel,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8D6E00), // Darker Gold Text
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Color(0xFF8D6E00),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFC0CA33),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isVerified = false,
    Color textColor = Colors.black87,
    Color iconColor = Colors.blueGrey,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Spacer(),
            if (isVerified) ...[
              const Icon(Icons.verified, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
