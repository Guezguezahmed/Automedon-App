import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Tout effacer', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationsAsync.when(
        data: (data) {
          final items = data['notifications'] as List;
          if (items.isEmpty) {
            return const Center(child: Text('Aucune notification'));
          }

          // Mock categorization since the API doesn't group them directly.
          // In a real app we would parse 'date' and group by today/this week.
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12, left: 4),
                child: Text('AUJOURD\'HUI', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              ...items.take(2).map((item) => _buildNotificationCard(item)),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(bottom: 12, left: 4),
                child: Text('CETTE SEMAINE', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              ...items.skip(2).map((item) => _buildNotificationCard(item)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final severity = item['severity'] as String? ?? 'info';
    Color iconColor;
    Color bgColor;
    IconData iconData;

    switch (severity) {
      case 'danger':
        iconColor = AppTheme.error;
        bgColor = AppTheme.error.withOpacity(0.1);
        iconData = Icons.close;
        break;
      case 'warning':
        iconColor = AppTheme.warning;
        bgColor = AppTheme.warning.withOpacity(0.1);
        iconData = Icons.warning_amber_rounded;
        break;
      case 'success':
        iconColor = AppTheme.success;
        bgColor = AppTheme.success.withOpacity(0.1);
        iconData = Icons.check_circle_outline;
        break;
      default:
        iconColor = AppTheme.primary;
        bgColor = AppTheme.primary.withOpacity(0.1);
        iconData = Icons.notifications_none;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(item['message'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(item['date'] ?? ''), 
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Color(0xFFD1D5DB), size: 20),
              onPressed: () {}, // read-only app
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(String isoDate) {
    // Simple mock formatting
    return "Il y a quelques instants";
  }
}
