import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtenir ou créer une conversation de façon ultra-robuste
  Future<String> getOrCreateConversation({
    required UserModel client,
    required String prestataireId,
    required String prestataireNom,
    required String prestatairePhoto,
    String? articleRefTitre,
    String? articleRefImageUrl,
  }) async {
    try {
      final query = await _db.collection('conversations').get();

      for (var doc in query.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        
        if (participants.contains(client.uid)) {
          return doc.id;
        }
      }

      final docRef = await _db.collection('conversations').add({
        'participants': [client.uid, prestataireId],
        'lastMessage': "Nouvelle conversation entamée",
        'lastMessageTime': FieldValue.serverTimestamp(),
        'prestataireNom': prestataireNom,
        'prestatairePhoto': prestatairePhoto,
        'clientNom': "${client.prenom} ${client.nom}",
        'clientPhoto': client.photoUrl ?? "",
        'articleRefTitre': articleRefTitre,
        'articleRefImageUrl': articleRefImageUrl,
      });

      return docRef.id;
    } catch (e) {
      debugPrint("❌ Erreur getOrCreateConversation: $e");
      return "conv_${client.uid}_${prestataireId.hashCode}";
    }
  }

  // Envoyer un message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    String? articleRefTitre,
    String? articleRefImageUrl,
  }) async {
    try {
      final message = ChatMessageModel(
        id: "",
        senderId: senderId,
        text: text,
        timestamp: DateTime.now(),
        articleRefTitre: articleRefTitre,
        articleRefImageUrl: articleRefImageUrl,
      );

      // 1. Ajouter le message dans la sous-collection
      await _db.collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(message.toMap());

      // 2. Mettre à jour la conversation parente (dernier message)
      await _db.collection('conversations').doc(conversationId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("❌ Erreur sendMessage: $e");
    }
  }

  // Écouter les messages d'une conversation
  Stream<List<ChatMessageModel>> getMessages(String conversationId) {
    return _db.collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  // Écouter TOUTES les conversations pour garantir que le prestataire ne rate rien
  Stream<List<ConversationModel>> getConversations(String userId) {
    return _db.collection('conversations')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
          return list;
        });
  }
}
