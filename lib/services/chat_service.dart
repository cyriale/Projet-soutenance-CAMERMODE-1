
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtenir ou créer une conversation
  Future<String> getOrCreateConversation({
    required UserModel client,
    required String prestataireId,
    required String prestataireNom,
    required String prestatairePhoto,
    String? articleRefTitre,
    String? articleRefImageUrl,
  }) async {
    // Chercher si une conv existe déjà entre ces deux là
    final query = await _db.collection('conversations')
        .where('participants', arrayContains: client.uid)
        .get();

    for (var doc in query.docs) {
      final participants = List<String>.from(doc.data()['participants']);
      if (participants.contains(prestataireId)) {
        return doc.id;
      }
    }

    // Sinon créer une nouvelle
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
  }

  // Envoyer un message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    String? articleRefTitre,
    String? articleRefImageUrl,
  }) async {
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
  }

  // Écouter les messages d'une conversation
  Stream<List<ChatMessageModel>> getMessages(String conversationId) {
    return _db.collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Écouter les conversations d'un utilisateur
  Stream<List<ConversationModel>> getConversations(String userId) {
    return _db.collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
