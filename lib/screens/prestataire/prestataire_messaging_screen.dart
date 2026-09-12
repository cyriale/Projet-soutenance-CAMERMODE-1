
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_colors.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../client/chat_conversation_screen.dart';

class PrestataireMessagingScreen extends StatelessWidget {
  const PrestataireMessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Messages Clients",
          style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<ConversationModel>>(
        stream: chatService.getConversations(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.rose));
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return const Center(
              child: Text("Aucun message client pour le moment."),
            );
          }

          return ListView.separated(
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
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: conv.clientPhoto.isNotEmpty ? NetworkImage(conv.clientPhoto) : null,
                    backgroundColor: Colors.grey[200],
                    child: conv.clientPhoto.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Row(
                    children: [
                      Text(
                        conv.clientNom,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        "${conv.lastMessageTime.hour.toString().padLeft(2, '0')}:${conv.lastMessageTime.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontSize: 11, color: AppColors.texteSecondaire),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    conv.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatConversationScreen(
                          conversationId: conv.id,
                          pName: conv.clientNom, // On inverse pour le pro
                          pPhoto: conv.clientPhoto,
                          prestataireVerified: false,
                          articleRefTitre: conv.articleRefTitre,
                          articleRefImageUrl: conv.articleRefImageUrl,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
