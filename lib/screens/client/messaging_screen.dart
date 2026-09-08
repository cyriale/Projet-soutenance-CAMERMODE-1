
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/dashboard_service.dart';
import 'chat_conversation_screen.dart';

class MessagingScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const MessagingScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final service = DashboardService();

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final conversations = service.conversations;

        return Scaffold(
          backgroundColor: AppColors.roseClair,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.noir),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else if (onBack != null) {
                  onBack!();
                }
              },
            ),
            title: const Text(
              "Messagerie & Échanges",
              style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold),
            ),
          ),
          body: conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Text(
                        "Aucune conversation en cours",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.noir),
                      ),
                      const SizedBox(height: 4),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Contactez un prestataire directement depuis la page d'une création pour échanger.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.texteSecondaire, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.ligne),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundImage: NetworkImage(conv.prestatairePhoto),
                            ),
                            if (conv.unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: AppColors.rose,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                conv.prestataireNom,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (conv.prestataireVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Colors.blue, size: 14),
                            ],
                            const Spacer(),
                            Text(
                              "${conv.lastMessageTime.hour.toString().padLeft(2, '0')}:${conv.lastMessageTime.minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(fontSize: 11, color: AppColors.texteSecondaire),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (conv.articleRefTitre != null) ...[
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.rose.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "À propos : ${conv.articleRefTitre}",
                                  style: const TextStyle(fontSize: 10, color: AppColors.rose, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              conv.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: conv.unreadCount > 0 ? AppColors.noir : AppColors.texteSecondaire,
                                fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatConversationScreen(
                                conversationId: conv.id,
                                prestataireNom: conv.prestataireNom,
                                prestatairePhoto: conv.prestatairePhoto,
                                prestataireVerified: conv.prestataireVerified,
                                articleRefTitre: conv.articleRefTitre,
                                articleRefImageUrl: conv.articleRefImageUrl,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
