
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';

class ShareSheet extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;

  const ShareSheet({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  static void show(BuildContext context, {
    required String title,
    required String description,
    String? imageUrl,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareSheet(
        title: title,
        description: description,
        imageUrl: imageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Partager cette création", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.noir)),
          const SizedBox(height: 4),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 13)),
          const SizedBox(height: 20),

          // Options de partage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareOption(
                context,
                icon: Icons.chat,
                color: Colors.green,
                label: "WhatsApp",
                action: "WhatsApp",
              ),
              _buildShareOption(
                context,
                icon: Icons.camera_alt,
                color: const Color(0xFFE1306C),
                label: "Instagram",
                action: "Instagram Stories",
              ),
              _buildShareOption(
                context,
                icon: Icons.facebook,
                color: Colors.blue[800]!,
                label: "Facebook",
                action: "Facebook",
              ),
              _buildShareOption(
                context,
                icon: Icons.copy,
                color: AppColors.noir,
                label: "Copier le lien",
                action: "copy",
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShareOption(BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String action,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (action == "copy") {
          Clipboard.setData(ClipboardData(text: "https://camermode.app/creations/$title"));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lien copié dans le presse-papier !"), backgroundColor: AppColors.noir),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Partage vers $action en cours..."), backgroundColor: color),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
