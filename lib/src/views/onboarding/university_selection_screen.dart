import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/providers/user_provider.dart';
import 'package:unihub_app/src/core/constants/env_config.dart';
import '../../core/helpers/url_helper.dart';
import '../shared/modern_loader.dart';

class UniversitySelectionScreen extends StatefulWidget {
  final bool isEditing;
  const UniversitySelectionScreen({super.key, this.isEditing = false});

  @override
  State<UniversitySelectionScreen> createState() =>
      _UniversitySelectionScreenState();
}

class _UniversitySelectionScreenState extends State<UniversitySelectionScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  List<dynamic> _universities = [];

  // Selection State
  int? _selectedUniversityId;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Re-using register lookups as it contains universities
      final data = await _authService.getRegisterLookups();
      if (mounted) {
        setState(() {
          _universities = data['universities'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _handleSelection() async {
    if (_selectedUniversityId == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Update Profile on Server
      // For now, we only update University.
      // If your app requires Faculty/Year selection immediately, we would show a bottom sheet or 2nd step here.
      // Assuming for this screen we just pick Uni first.

      final updatedUser = await _authService.updateProfile({
        'university_id': _selectedUniversityId,
        // 'academic_year_id': ... // You might want to ask this in next step
      });

      // 2. Update Local User
      if (mounted) {
        context.read<UserProvider>().setUser(updatedUser);

        // 3. Navigate Home or Back
        if (widget.isEditing) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showConfirmationDialog(dynamic uni) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // University Name
                Text(
                  uni['name'] ?? '',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),

                // Welcome Text
                Text(
                  'أهلا وسهلا فيك',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Enter Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      _handleSelection(); // Proceed with selection
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E6FF2), // Bright Blue
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'الدخول إلى الجامعة',
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFEBFDFD,
      ), // Azureish background like image
      body: SafeArea(
        child: _isLoading
            ? const Center(child: ModernLoader())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'اختر جامعتك',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Balance row for centered title or just leave expanded
                        const SizedBox(
                          width: 48,
                        ), // Match icon button width for perfect centering if needed
                      ],
                    ),
                    const SizedBox(height: 30),

                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.9,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: _universities.length,
                        itemBuilder: (context, index) {
                          final uni = _universities[index];
                          // Highlight if selected (though it will load immediately now)
                          final isSelected = _selectedUniversityId == uni['id'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedUniversityId = uni['id'];
                              });
                              _showConfirmationDialog(uni);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.amber
                                      : Colors.amber.withOpacity(0.3),
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Logo
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: uni['logo_url'] != null
                                          ? Image.network(
                                              UrlHelper.fixUrl(
                                                uni['logo_url']
                                                        .toString()
                                                        .startsWith('http')
                                                    ? uni['logo_url']
                                                    : '${EnvConfig.apiBaseUrl.replaceAll('/api', '')}/cors-storage/${uni['logo_url']}',
                                              ),
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                    Icons.school,
                                                    size: 50,
                                                    color: Colors.indigo,
                                                  ),
                                            )
                                          : const Icon(
                                              Icons.school,
                                              size: 50,
                                              color: Colors.indigo,
                                            ),
                                    ),
                                  ),

                                  // Name
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      uni['name'],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
