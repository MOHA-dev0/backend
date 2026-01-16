import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/wallet_service.dart';
import '../widgets/wallet_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _voucherController = TextEditingController();
  final _walletService = WalletService();
  bool _isLoading = false;

  Future<void> _redeem() async {
    if (_voucherController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final newBalance = await _walletService.redeemVoucher(_voucherController.text.trim());
      
      if (mounted) {
        // Update Global User State
        final userProvider = context.read<UserProvider>();
        // We'd ideally update the user object fully, but for now we trust the refresh
        userProvider.refreshUser(); // Should implement simple local balance update too
        
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Success! New Balance: ${newBalance.toStringAsFixed(0)} SYP')),
        );
        _voucherController.clear();
        Navigator.pop(context); // Go back to Home to see update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WalletCard(
              balance: user?.balance ?? 0.0,
              onTap: () {},
            ),
            const SizedBox(height: 32),
            
            Text(
              'Top Up Balance',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _voucherController,
              decoration: InputDecoration(
                labelText: 'Voucher Code',
                hintText: 'Enter 12-digit code',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
              ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _redeem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Redeem Voucher'),
            ),
          ],
        ).animate().fadeIn().slideY(begin: 0.1),
      ),
    );
  }
}
