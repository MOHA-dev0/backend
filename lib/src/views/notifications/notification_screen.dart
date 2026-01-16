import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/providers/user_provider.dart';
import '../../core/constants/env_config.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await context.read<UserProvider>().getToken();
      if (token != null && mounted) {
        await context.read<NotificationService>().fetchNotifications(token);
        if (mounted) {
          context.read<NotificationService>().markAllAsRead();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white, // White Background
        appBar: AppBar(
          backgroundColor: Colors.blue, // Blue Header
          elevation: 0,
          title: const Text(
            'الإشعارات',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: Colors.grey[300], // Grey background for unselected
              child: TabBar(
                indicator: const BoxDecoration(
                  color: Color(0xFFD4AF37), // Solid Gold for Selected
                ),
                indicatorSize: TabBarIndicatorSize.tab, // Fill the full tab
                labelColor: Colors.white, // Selected text color
                unselectedLabelColor: Colors.black, // Unselected text color
                tabs: const [
                  Tab(text: 'إشعاراتي'),
                  Tab(text: 'إشعارات التطبيق'),
                ],
              ),
            ),
          ),
        ),
        body: Consumer<NotificationService>(
          builder: (context, service, _) {
            if (service.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                // Tab 1: Personal Notifications
                _buildPersonalList(service.personalNotifications),
                // Tab 2: System Notifications
                _buildSystemList(context, service.notifications),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPersonalList(List<dynamic> notifications) {
    if (notifications.isEmpty) {
      return const Center(child: Text('لا توجد إشعارات حالياً'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final title = notification.data['title'] ?? 'إشعار جديد';
        final body = notification.data['body'] ?? '';

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (body.isNotEmpty) ...[const SizedBox(height: 8), Text(body)],
                const SizedBox(height: 8),
                Text(
                  _formatDate(notification.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSystemList(BuildContext context, List<dynamic> notifications) {
    if (notifications.isEmpty) {
      return const Center(child: Text('لا توجد إشعارات حالياً'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(notification.body),
                if (notification.image != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Builder(
                      builder: (context) {
                        final imageUrl =
                            '${EnvConfig.apiBaseUrl.replaceAll('/api', '')}/cors-storage/${notification.image}';
                        debugPrint('Loading Notification Image: $imageUrl');
                        return Image.network(
                          imageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, error, stackTrace) {
                            return Container(
                              height: 150,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'تعذر تحميل الصورة',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
                if (notification.link != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () => _launchURL(notification.link!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('عرض المزيد'),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _formatDate(notification.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}';
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}
