
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String? articleRefTitre;
  final String? articleRefImageUrl;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.articleRefTitre,
    this.articleRefImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'articleRefTitre': articleRefTitre,
      'articleRefImageUrl': articleRefImageUrl,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] is Timestamp ? (map['timestamp'] as Timestamp).toDate() : DateTime.tryParse(map['timestamp']) ?? DateTime.now())
          : DateTime.now(),
      articleRefTitre: map['articleRefTitre'],
      articleRefImageUrl: map['articleRefImageUrl'],
    );
  }
}

class ConversationModel {
  final String id;
  final List<String> participants; // [userId, prestataireId]
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? articleRefTitre;
  final String? articleRefImageUrl;
  
  // Cache pour l'affichage rapide (denormalisation)
  final String prestataireNom;
  final String prestatairePhoto;
  final String clientNom;
  final String clientPhoto;

  ConversationModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    this.articleRefTitre,
    this.articleRefImageUrl,
    required this.prestataireNom,
    required this.prestatairePhoto,
    required this.clientNom,
    required this.clientPhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'articleRefTitre': articleRefTitre,
      'articleRefImageUrl': articleRefImageUrl,
      'prestataireNom': prestataireNom,
      'prestatairePhoto': prestatairePhoto,
      'clientNom': clientNom,
      'clientPhoto': clientPhoto,
    };
  }

  factory ConversationModel.fromMap(Map<String, dynamic> map, String id) {
    return ConversationModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null 
          ? (map['lastMessageTime'] is Timestamp ? (map['lastMessageTime'] as Timestamp).toDate() : DateTime.tryParse(map['lastMessageTime']) ?? DateTime.now())
          : DateTime.now(),
      articleRefTitre: map['articleRefTitre'],
      articleRefImageUrl: map['articleRefImageUrl'],
      prestataireNom: map['prestataireNom'] ?? 'Prestataire',
      prestatairePhoto: map['prestatairePhoto'] ?? '',
      clientNom: map['clientNom'] ?? 'Client',
      clientPhoto: map['clientPhoto'] ?? '',
    );
  }
}
