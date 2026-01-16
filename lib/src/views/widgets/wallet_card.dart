import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletCard extends StatelessWidget {
  final double balance;
  final VoidCallback onTap;

  const WalletCard({
    super.key,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.account_balance_wallet,
                size: 150,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Universal Wallet',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    Icon(Icons.nfc, color: Colors.white.withOpacity(0.8)),
                  ],
                ),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL BALANCE',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${balance.toStringAsFixed(0)} SYP',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  ],
                ),

                Row(
                  children: [
                    Text(
                      '**** **** **** 1234',
                      style: GoogleFonts.sourceCodePro(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).moveY(begin: 30, end: 0),
    );
  }
}
