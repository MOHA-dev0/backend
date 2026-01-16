import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectCard extends StatelessWidget {
  final String title;
  final String? code;
  final String? imageUrl;
  final String accessType; // 'gold', 'silver', 'diamond', or 'none'
  final VoidCallback onTap;
  final double progress; // 0.0 to 1.0

  const SubjectCard({
    super.key,
    required this.title,
    this.code,
    this.imageUrl,
    required this.accessType,
    required this.onTap,
    this.progress = 0.0,
  });

  Color _getAccessColor() {
    switch (accessType) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'diamond':
        return const Color(0xFFB9F2FF);
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image Area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                // Access Badge
                if (accessType != 'none')
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getAccessColor(), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: _getAccessColor(), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            accessType.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: _getAccessColor(),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  ),
              ],
            ),
            
            // Content Area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (code != null)
                    Text(
                      code!,
                      style: GoogleFonts.outfit(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Progress Bar (if purchased)
                  if (accessType != 'none') ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: GoogleFonts.outfit(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                     Row(
                      children: [
                        Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to purchase',
                          style: GoogleFonts.outfit(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                     ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).moveY(begin: 20, end: 0),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(Icons.book_rounded, size: 48, color: Colors.grey.shade300),
      ),
    );
  }
}
