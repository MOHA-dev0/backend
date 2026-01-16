import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/user_provider.dart';

class ActivationPendingScreen extends StatelessWidget {
  const ActivationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBFDFD), // Premium light background
      body: RefreshIndicator(
        onRefresh: () async {
          final provider = context.read<UserProvider>();
          await provider.refreshUser();
          final user = provider.user;
          if (context.mounted && user != null) {
            // If now verified (or restricted which allows access), go home
            if (user.status != 'unverified') {
              // Navigate based on uni selection
              if (user.universityId == null) {
                Navigator.pushReplacementNamed(context, '/university');
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الحساب لا يزال قيد التفعيل')),
              );
            }
          }
        },
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Ensure pull works even if content fits
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium Card Effect
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_clock,
                          size: 50,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'الحساب قيد التفعيل',
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Message
                      Text(
                        'يرجى التواصل مع الرقم 059 لتفعيل حسابك والبدء في الدراسة\n\nاسحب للأسفل لتحديث الحالة',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Contact Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Ideally launch WhatsApp or Call
                          },
                          icon: const Icon(Icons.phone),
                          label: Text(
                            'تواصل معنا (059)',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF25D366,
                            ), // WhatsApp Green
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Logout Button
                TextButton.icon(
                  onPressed: () {
                    // Logout Logic
                    context.read<UserProvider>().logout();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(
                    'تسجيل الخروج',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
