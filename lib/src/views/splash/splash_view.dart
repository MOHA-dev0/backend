import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/config_provider.dart';
import '../auth/login_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Enforce Security (Android)
    try {
      await ScreenProtector.protectDataLeakageOn();
    } catch (e) {
      debugPrint('Security Flag Error: $e');
    }

    // 2. Load Config
    final configProvider = context.read<ConfigProvider>();
    await configProvider.loadConfig(); // Fixed method name

    // 3. Navigate based on onboarding state
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => hasSeenOnboarding ? const LoginScreen() : const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a default logo or the cached one if available immediately
    final config = context.watch<ConfigProvider>().config;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for Logo
            Icon(Icons.school, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Color(0xFF1877F2),
            ),
          ],
        ),
      ),
    );
  }
}
