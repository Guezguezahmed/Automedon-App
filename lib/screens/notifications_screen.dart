import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/kit.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final Set<String> _dismissedKeys = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);

    return AppAmbientGlow(
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
        title: Text('Notifications', style: AppTextStyles.displayLg(color: isDark ? Colors.white : AppTheme.ink900)),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => _clearAll(notificationsAsync.value),
            child: Text(
              'Tout effacer',
              style: AppTextStyles.bodyLg(color: isDark ? AppTheme.neonViolet : AppTheme.primary600),
            ),
          ),
          const SizedBox(width: AppTheme.sp2),
        ],
      ),
      body: notificationsAsync.when(
        data: (data) {
          final allItems = data['notifications'] as List;
          final items = allItems
              .where((item) => !_dismissedKeys.contains(item['key'] as String?))
              .toList();

          if (items.isEmpty) {
            return Center(
              child: Text(
                'Aucune notification',
                style: AppTextStyles.bodyLg(color: AppTheme.ink400),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppTheme.sp4),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.sp3, left: AppTheme.sp1),
                child: Text(
                  'AUJOURD\'HUI',
                  style: AppTextStyles.caption(color: AppTheme.ink600),
                ),
              ),
              ...items.take(2).map((item) => _buildNotificationCard(context, item)),
              const SizedBox(height: AppTheme.sp4),
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.sp3, left: AppTheme.sp1),
                child: Text(
                  'CETTE SEMAINE',
                  style: AppTextStyles.caption(color: AppTheme.ink600),
                ),
              ),
              ...items.skip(2).map((item) => _buildNotificationCard(context, item)),
              const SizedBox(height: 100),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Erreur: $err',
            style: AppTextStyles.bodyLg(color: AppTheme.danger),
          ),
        ),
      ),
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
        iconColor = AppTheme.danger;
        bgColor = AppTheme.danger.withValues(alpha: 0.1);
        iconData = Icons.close;
        break;
      case 'warning':
        iconColor = AppTheme.warning;
        bgColor = AppTheme.warning.withValues(alpha: 0.1);
        iconData = Icons.warning_amber_rounded;
        break;
      case 'success':
        iconColor = AppTheme.success;
        bgColor = AppTheme.success.withValues(alpha: 0.1);
        iconData = Icons.check_circle_outline;
        break;
      default:
        iconColor = AppTheme.primary600;
        bgColor = AppTheme.primary600.withValues(alpha: 0.1);
        iconData = Icons.notifications_none;
    }

    final card = Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.sp3),
      child: AppCard(
        padding: const EdgeInsets.all(AppTheme.sp4),
        shadows: AppTheme.shadowSm,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconCircle(
              icon: iconData,
              color: iconColor,
              backgroundColor: bgColor,
              size: 40,
              iconSize: 20,
            ),
            const SizedBox(width: AppTheme.sp4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: AppTextStyles.bodyLg(color: AppTheme.ink900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['message'] ?? '',
                    style: AppTextStyles.bodyMd(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(item['date'] ?? ''),
                    style: AppTextStyles.caption(color: AppTheme.ink600),
                  ),
                ],
              ),
            ),
            if (reservationId != null)
              const Icon(Icons.chevron_right, color: AppTheme.ink400, size: 20)
            else
              IconButton(
                icon: const Icon(Icons.cancel_outlined, color: AppTheme.ink400, size: 20),
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
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      onTap: () => context.push('/reservations/$reservationId'),
      child: card,
    );
  }

  String _formatDate(String isoDate) {
    return "Il y a quelques instants";
  }
}