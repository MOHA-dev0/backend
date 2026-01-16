import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/providers/config_provider.dart';
import 'home/home_screen.dart';
import 'cart/cart_screen.dart';
import 'notifications/notification_screen.dart';
import 'settings/settings_screen.dart';

import '../core/services/notification_service.dart';
import '../core/providers/user_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await context.read<UserProvider>().getToken();
      if (token != null && mounted) {
        context.read<NotificationService>().fetchNotifications(token);
      }
    });
  }

  int _selectedIndex = 0; // Default to Home

  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const NotificationScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>().config;
    final primaryColor = config.primaryColor;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.white, // Text/Icon color when active
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: primaryColor, // Pill color
              color: Colors.grey, // Inactive icon color
              tabs: [
                GButton(
                  icon: Icons.home_rounded,
                  text: 'الرئيسية',
                  textStyle: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GButton(
                  icon: Icons.shopping_basket_rounded, // or shopping_cart
                  text: 'سلتي',
                  textStyle: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GButton(
                  icon: Icons.notifications_rounded,
                  leading: Consumer<NotificationService>(
                    builder: (context, service, child) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.notifications_rounded,
                            size: 24,
                            color: _selectedIndex == 2
                                ? Colors.white
                                : Colors.grey,
                          ),
                          if (service.unreadCount > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${service.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  text: 'الإشعارات',
                  textStyle: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GButton(
                  icon: Icons.settings_rounded,
                  text: 'الضبط', // Settings
                  textStyle: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
