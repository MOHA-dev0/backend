import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import '../../core/providers/config_provider.dart';

enum LegalType {
  privacyPolicy,
  termsOfUse,
}

class LegalScreen extends StatelessWidget {
  final String title;
  final LegalType type;

  const LegalScreen({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final configProvider = context.watch<ConfigProvider>();
    final config = configProvider.config;

    String content = '';
    switch (type) {
      case LegalType.privacyPolicy:
        content = config.privacyPolicy;
        break;
      case LegalType.termsOfUse:
        content = config.termsOfUse;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: config.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<ConfigProvider>().loadConfig();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 100, // Ensure scrollability
            ),
            child: content.isEmpty
                ? const Center(child: Text("No content available."))
                : HtmlWidget(
                    content,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }
}
