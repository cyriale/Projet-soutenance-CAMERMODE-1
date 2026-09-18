import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/chat_service.dart';
import '../chat_conversation_screen.dart';
import '../booking_dialog.dart';
import '../../../models/article_model.dart';

/// Composant pour les boutons d'action (Contacter et Réserver)
class ProviderActionButtons extends StatelessWidget {
  final String prestataireId;
  final String nom;
  final String photoUrl;
  final bool isVerified;
  final List<ArticleModel> articles;

  const ProviderActionButtons({
    super.key,
    required this.prestataireId,
    required this.nom,
    required this.photoUrl,
    required this.isVerified,
    required this.articles,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Bouton Contacter (Ouvre le Chat)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final chatService = ChatService();
                final auth = AuthService();
                final currentUser = await auth.onAuthStateChanged.first;

                if (currentUser != null) {
                  final String convId = await chatService.getOrCreateConversation(
                    client: currentUser,
                    prestataireId: prestataireId,
                    prestataireNom: nom,
                    prestatairePhoto: photoUrl,
                  );
                  
                  if (!context.mounted) return;
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatConversationScreen(
                        conversationId: convId,
                        pName: nom,
                        pPhoto: photoUrl,
                        prestataireVerified: isVerified,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.chat_bubble_outline, color: AppColors.noir, size: 18),
              label: const Text("Contacter", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.ligne),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Bouton Réserver (Ouvre le dialogue de réservation)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (articles.isNotEmpty) {
                  BookingDialog.show(context, articles.first);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sélectionnez une création pour réserver.")),
                  );
                }
              },
              icon: const Icon(Icons.calendar_month, color: Colors.white, size: 18),
              label: const Text("Réserver", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rose,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
