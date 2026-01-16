import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'src/core/providers/config_provider.dart';
import 'src/core/providers/user_provider.dart';
import 'src/core/theme/app_theme.dart';
import 'src/views/auth/login_screen.dart';
import 'src/core/services/notification_service.dart';

import 'src/views/onboarding/university_selection_screen.dart';
import 'src/views/splash_screen.dart';
import 'src/views/main_screen.dart';
import 'src/views/auth/activation_pending_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UniHubApp());
}

class UniHubApp extends StatelessWidget {
  const UniHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfigProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: Consumer<ConfigProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'UniHub',
            debugShowCheckedModeBanner: false,
            // Localization
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'AE'), // Arabic as primary
            ],
            locale: const Locale('ar', 'AE'),

            // Dynamic Themes
            theme: AppTheme.light(provider.config),
            darkTheme: AppTheme.dark(provider.config),
            themeMode: ThemeMode.system,

            home: const SplashScreen(),
            routes: {
              '/login': (context) => LoginScreen(),
              '/home': (context) => const MainScreen(),
              '/university': (context) => const UniversitySelectionScreen(),
              '/activation_pending': (context) =>
                  const ActivationPendingScreen(),
            },
          );
        },
      ),
    );
  }
}

class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>().config;
    return Scaffold(
      appBar: AppBar(title: const Text('Al-Rasikhoon')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Al-Rasikhoon',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: config.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              color: config.secondaryColor,
              child: const Center(child: Text('Secondary')),
            ),
          ],
        ),
      ),
    );
  }
}
