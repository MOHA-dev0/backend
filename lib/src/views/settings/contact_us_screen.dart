import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/config_provider.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  int? _expandedId;

  @override
  Widget build(BuildContext context) {
    // Fetch config for primary color
    final configProvider = context.watch<ConfigProvider>();
    final primaryColor = configProvider.config.primaryColor;
    
    // Fetch and prepare links
    final links = configProvider.links
        .where((l) => l.type == 'social' && l.isActive)
        .toList();

    // Extract Phone Link (Call Now) - Keep separate as it's a primary action
    final phoneLinkIndex = links.indexWhere((l) => l.icon != null && (l.icon!.toLowerCase().contains('phone') || l.icon!.toLowerCase().contains('call')));
    var phoneLink = phoneLinkIndex != -1 ? links[phoneLinkIndex] : null;

    // Remaining links are ALL Expandable Social Buttons
    final socialLinks = [...links];
    if (phoneLink != null) socialLinks.remove(phoneLink);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom Blue Header (Matching App Theme) - SQUARE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            decoration: BoxDecoration(
              color: primaryColor, 
              // NO BorderRadius (Square)
              boxShadow: const [
                 BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))
              ],
            ),
            child: Row(
              children: [
                // Back Button
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white)
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'معلومات التواصل',
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24), // Balance the back button
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quote
                  Text(
                    'والراسخون في العلم يقولون آمنا به....\nمن هنا كانت البداية',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Call Button (Gold) - Remains simple action? Or expand? 
                  // User said "click the icon of youtube...". Phone usually calls directly. I'll keep Call direct.
                  if (phoneLink != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCDC346), // Gold/Olive
                          borderRadius: BorderRadius.zero,
                          boxShadow: [
                             BoxShadow(color: const Color(0xFFCDC346).withOpacity(0.4), blurRadius: 10, offset: const Offset(0,5)),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => launchUrl(Uri.parse(phoneLink!.url), mode: LaunchMode.externalApplication),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const SizedBox(width: 28),
                                  Expanded(
                                    child: Text(
                                      'اتصل الآن',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.cairo(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.phone_in_talk, color: Colors.white, size: 28),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Subtitle "Social Identifiers"
                  if (socialLinks.isNotEmpty) ...[
                    Text(
                      'معرفات التواصل الاجتماعي',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (socialLinks.isEmpty && phoneLink == null)
                     Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'لا توجد معلومات تواصل مضافة حالياً',
                          style: GoogleFonts.cairo(color: Colors.grey),
                        ),
                      ),
                    ),

                  // Expandable Social Buttons
                  ...socialLinks.map((link) {
                     return _buildExpandableSocialButton(link);
                  }).toList(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSocialButton(dynamic link) { // Using dynamic for ImportantLink type
    bool isExpanded = _expandedId == link.id;

    // Determine Style based on Icon
    Color btnColor = _getColorForHex(link.color) ?? Colors.grey;
    IconData iconData = Icons.link;
    String brandLabel = link.title; // Default fallback
    
    final name = link.icon?.toLowerCase() ?? '';
    
    if (name.contains('whatsapp')) {
      btnColor = const Color(0xFF25D366);
      iconData = FontAwesomeIcons.whatsapp;
      brandLabel = "WhatsApp";
    } else if (name.contains('facebook')) {
      btnColor = const Color(0xFF1877F2);
      iconData = FontAwesomeIcons.facebookF;
      brandLabel = "Facebook";
    } else if (name.contains('telegram')) {
      btnColor = const Color(0xFF0088CC);
      iconData = FontAwesomeIcons.telegram;
      brandLabel = "Telegram";
    } else if (name.contains('instagram')) {
      btnColor = const Color(0xFFE4405F);
      iconData = FontAwesomeIcons.instagram;
      brandLabel = "Instagram";
    } else if (name.contains('youtube')) {
      btnColor = const Color(0xFFFF0000);
      iconData = FontAwesomeIcons.youtube;
      brandLabel = "YouTube";
    } else {
        // Fallback for custom or unknown
        iconData = _getIconForName(link.icon);
    }
    
    // Icon on Left (End in RTL)
    // Align: [Spacer, Text(Center), Icon]

    return Column(
      children: [
        // Main Button (Click toggles Expand)
        Container(
          height: 55,
          margin: const EdgeInsets.only(bottom: 0), // Connected if expanded
          decoration: BoxDecoration(
            color: btnColor,
            borderRadius: BorderRadius.zero, // Square
             boxShadow: [
                 BoxShadow(color: btnColor.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 4)),
             ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedId = null;
                  } else {
                    _expandedId = link.id;
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                     // If expanded, show arrow? Or just click to toggle.
                     
                    const SizedBox(width: 28), 
                    Expanded(
                      child: Text(
                        brandLabel, // "YouTube", "Facebook" etc.
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white,
                          height: 1.2
                        ),
                      ),
                    ),
                    
                    name.contains('whatsapp') || name.contains('facebook') || name.contains('telegram') || name.contains('instagram') || name.contains('youtube') 
                      ? FaIcon(iconData, color: Colors.white, size: 28)
                      : Icon(iconData, color: Colors.white, size: 28),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Expanded Content (Popup)
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: isExpanded ? Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.zero, // Square bottom
            ),
            child: Column(
              children: [
                // Text Message (Title from Dashboard)
                Text(
                  link.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                     fontSize: 15,
                     color: Colors.black87,
                     fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Join Button
                SizedBox(
                  width: 120, // Small button
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication),
                    style: ElevatedButton.styleFrom(
                       backgroundColor: btnColor, // Use brand color for join button too? Or primary blue? User said "Join button". Usually action color.
                       // Let's use the Brand Color for consistency or Primary.
                       // "there's a join button when clicked it opens the link"
                       // I'll use Brand Color to link it visually.
                       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: Text(
                      'إنضمام',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ) : const SizedBox(height: 12), // Spacing when closed
        ),
      ],
    );
  }
  IconData _getIconForName(String? name) {
    if (name == null) return Icons.link;
    name = name.toLowerCase();
    if (name.contains('whatsapp')) return Icons.phone;
    if (name.contains('facebook')) return Icons.facebook;
    if (name.contains('telegram')) return Icons.send;
    if (name.contains('instagram')) return Icons.camera_alt;
    if (name.contains('youtube')) return Icons.video_library;
    if (name.contains('phone') || name.contains('call')) return Icons.call;
    return Icons.link;
  }

  Color? _getColorForHex(String? hexColor) {
    if (hexColor == null) return null;
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
