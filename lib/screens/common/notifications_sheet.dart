import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifService = NotificationService();
    final currentUserId = AuthService().currentUser?.uid ?? "";

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active, color: AppColors.rose, size: 22),
                    SizedBox(width: 8),
                    Text(
                      "Mes Notifications",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.noir),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => notifService.markAllAsRead(currentUserId),
                  child: const Text("Tout lire", style: TextStyle(color: AppColors.rose, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<InAppNotificationModel>>(
              stream: notifService.getUserNotifications(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.rose));
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 50, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        const Text(
                          "Aucune notification pour le moment",
                          style: TextStyle(color: AppColors.texteSecondaire, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      tileColor: n.isRead ? Colors.white : AppColors.rose.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: CircleAvatar(
                        backgroundColor: _getIconColor(n.type).withValues(alpha: 0.15),
                        child: Icon(_getIconData(n.type), color: _getIconColor(n.type), size: 20),
                      ),
                      title: Text(
                        n.title,
                        style: TextStyle(
                          fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(n.body, style: const TextStyle(fontSize: 12, color: AppColors.noir)),
                          const SizedBox(height: 4),
                          Text(
                            "${n.createdAt.day}/${n.createdAt.month}/${n.createdAt.year} à ${n.createdAt.hour.toString().padLeft(2, '0')}:${n.createdAt.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(fontSize: 10, color: AppColors.texteSecondaire),
                          ),
                        ],
                      ),
                      onTap: () {
                        if (!n.isRead) {
                          notifService.markAsRead(n.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconColor(String type) {
    if (type.contains('status') || type.contains('confirm')) return Colors.green;
    if (type.contains('refus') || type.contains('cancel')) return Colors.red;
    if (type.contains('new') || type.contains('reservation')) return AppColors.rose;
    return Colors.blue;
  }

  IconData _getIconData(String type) {
    if (type.contains('status') || type.contains('confirm')) return Icons.check_circle_outline;
    if (type.contains('refus') || type.contains('cancel')) return Icons.cancel_outlined;
    if (type.contains('new') || type.contains('reservation')) return Icons.calendar_month;
    return Icons.notifications_none;
  }
}
