import 'package:flutter/material.dart';

class ImportantLink {
  final int id;
  final String title;
  final String url;
  final String type;
  final String? icon;
  final String? color;
  final bool isActive;

  ImportantLink({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    this.icon,
    this.color,
    this.isActive = true,
  });

  factory ImportantLink.fromJson(Map<String, dynamic> json) {
    return ImportantLink(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      type: json['type'],
      icon: json['icon'],
      color: json['color'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}
