import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class NotificationSettingsSheet extends StatefulWidget {
  final bool isPrestataire;

  const NotificationSettingsSheet({super.key, this.isPrestataire = false});

  static void show(BuildContext context, {bool isPrestataire = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationSettingsSheet(isPrestataire: isPrestataire),
    );
  }

  @override
  State<NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  bool _pushEnabled = true;
  bool _reservationsAlert = true;
  bool _messagesAlert = true;
  bool _marketingAlert = false;
  bool _remindersAlert = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.rose.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_outlined, color: AppColors.rose, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  "Paramètres des Notifications",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.noir),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Activer toutes les notifications", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Recevoir des alertes sur cet appareil", style: TextStyle(fontSize: 12)),
            value: _pushEnabled,
            activeColor: AppColors.rose,
            onChanged: (v) => setState(() => _pushEnabled = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              widget.isPrestataire ? "Nouvelles demandes de rendez-vous" : "Confirmations de réservations",
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: const Text("Alertes instantanées", style: TextStyle(fontSize: 12)),
            value: _pushEnabled && _reservationsAlert,
            activeColor: AppColors.rose,
            onChanged: _pushEnabled ? (v) => setState(() => _reservationsAlert = v) : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Nouveaux messages", style: TextStyle(fontSize: 14)),
            subtitle: const Text("Discussions avec clients et artisans", style: TextStyle(fontSize: 12)),
            value: _pushEnabled && _messagesAlert,
            activeColor: AppColors.rose,
            onChanged: _pushEnabled ? (v) => setState(() => _messagesAlert = v) : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Rappels de rendez-vous", style: TextStyle(fontSize: 14)),
            subtitle: const Text("Rappels 24h avant la prestation", style: TextStyle(fontSize: 12)),
            value: _pushEnabled && _remindersAlert,
            activeColor: AppColors.rose,
            onChanged: _pushEnabled ? (v) => setState(() => _remindersAlert = v) : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Offres et Nouveautés CamerMode", style: TextStyle(fontSize: 14)),
            subtitle: const Text("Inspirations stylistiques et tendances", style: TextStyle(fontSize: 12)),
            value: _pushEnabled && _marketingAlert,
            activeColor: AppColors.rose,
            onChanged: _pushEnabled ? (v) => setState(() => _marketingAlert = v) : null,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Préférences de notifications mises à jour !"),
                    backgroundColor: AppColors.succes,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rose,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("ENREGISTRER MES PRÉFÉRENCES", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
