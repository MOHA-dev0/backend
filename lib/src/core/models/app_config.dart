import 'package:flutter/material.dart';

class AppConfig {
  final Color primaryColor;
  final Color secondaryColor;
  final String fontFamily;
  final String splashImageUrl;
  final String privacyPolicy;
  final String termsOfUse;
  final String shareLink;
  final String shareText;
  final int discount2Items;
  final int discount3Items;

  AppConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.fontFamily,
    required this.splashImageUrl,
    required this.privacyPolicy,
    required this.termsOfUse,
    required this.shareLink,
    required this.shareText,
    required this.discount2Items,
    required this.discount3Items,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      primaryColor: _parseHex(json['primary_color'] ?? '#1877F2'),
      secondaryColor: _parseHex(json['secondary_color'] ?? '#FFD700'),
      fontFamily: json['font_family'] ?? 'Inter',
      splashImageUrl: json['splash_image_url'] ?? '',
      privacyPolicy: json['privacy_policy'] ?? '',
      termsOfUse: json['terms_of_use'] ?? '',
      shareLink: json['share_link'] ?? 'https://alrasikhoon.com',
      shareText: json['share_text'] ?? 'Check out this app!',
      discount2Items: json['discount_2_items'] ?? 0,
      discount3Items: json['discount_3_items'] ?? 0,
    );
  }

  factory AppConfig.defaults() {
    return AppConfig(
      primaryColor: const Color(0xFF2196F3),
      secondaryColor: const Color(0xFFFFD700),
      fontFamily: 'Inter',
      splashImageUrl: '',
      privacyPolicy: '',
      termsOfUse: '',
      shareLink: 'https://alrasikhoon.com',
      shareText: 'Check out this app!',
      discount2Items: 0,
      discount3Items: 0,
    );
  }

  static Color _parseHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}
