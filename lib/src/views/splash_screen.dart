import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../core/services/auth_service.dart';
import '../core/providers/user_provider.dart';
import '../core/providers/config_provider.dart';
import 'shared/modern_loader.dart';
import '../core/utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  final _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
    _initApp();
  }

  Future<void> _initApp() async {
    // Start minimum wait time
    final minWait = Future.delayed(const Duration(seconds: 2));

    // Attempt data fetch with timeout
    final dataFetch = _authService
        .getRegisterLookups()
        .timeout(const Duration(seconds: 8))
        .catchError((e) {
          debugPrint('Splash Data Fetch Error: $e');
          return <String, dynamic>{}; // Return empty map
        });

    // Fetch Config (Settings, Share Text, etc.)
    final configFetch = context.read<ConfigProvider>().loadConfig();

    // Wait for all
    await Future.wait<dynamic>([minWait, dataFetch, configFetch]);

    // Read token
    final token = await _storage.read(key: 'auth_token');

    // Reverse animation
    if (mounted) {
      try {
        await _controller.reverse().orCancel;
      } catch (e) {
        // Ignore cancellation errors
      }
    }

    if (mounted) {
      if (token != null) {
        try {
          // Verify token and get fresh user data
          await context.read<UserProvider>().refreshUser();
          final user = context.read<UserProvider>().user;

          if (user != null) {
            // Check for University Selection
            if (user.universityId == null) {
              Navigator.pushReplacementNamed(context, '/university');
            } else {
              // Verified, Unverified, Restricted - All go to Home
              Navigator.pushReplacementNamed(context, '/home');
            }
          } else {
            // Fallback if user is null after refresh (token invalid or error)
            Navigator.pushReplacementNamed(context, '/login');
          }
        } catch (e) {
          debugPrint('Session restore failed: $e');
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 200),
              const SizedBox(height: 20),
              // Modern Loader
              const SizedBox(
                height: 50,
                child: ModernLoader(color: AppColors.primary, size: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
