import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // Locally dismissed notification keys (per API spec §4.6: `key` is the
  // stable unique id meant for local de-duplication / "mark as read").
  final Set<String> _dismissedKeys = {};

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => _clearAll(notificationsAsync.value),
            child: const Text('Tout effacer', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationsAsync.when(
        data: (data) {
          final allItems = data['notifications'] as List;
          final items = allItems
              .where((item) => !_dismissedKeys.contains(item['key'] as String?))
              .toList();

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
              ...items.take(2).map((item) => _buildNotificationCard(context, item)),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(bottom: 12, left: 4),
                child: Text('CETTE SEMAINE', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              ...items.skip(2).map((item) => _buildNotificationCard(context, item)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  void _clearAll(Map<String, dynamic>? data) {
    if (data == null) return;
    final allItems = data['notifications'] as List;
    setState(() {
      for (final item in allItems) {
        final key = item['key'] as String?;
        if (key != null) _dismissedKeys.add(key);
      }
    });
  }

  void _dismiss(String? key) {
    if (key == null) return;
    setState(() => _dismissedKeys.add(key));
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, dynamic> item) {
    final severity = item['severity'] as String? ?? 'info';
    final type = item['type'] as String?;
    final key = item['key'] as String?;
    final ref = item['ref'] as Map<String, dynamic>?;
    final reservationId = (type == 'return_due') ? (ref?['reservation_id'] as int?) : null;

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

    final card = Card(
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
            if (reservationId != null)
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20)
            else
              IconButton(
                icon: const Icon(Icons.cancel_outlined, color: Color(0xFFD1D5DB), size: 20),
                onPressed: () => _dismiss(key),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );

    if (reservationId == null) return card;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/reservations/$reservationId'),
      child: card,
    );
  }

  String _formatDate(String isoDate) {
    // Simple mock formatting
    return "Il y a quelques instants";
  }
}