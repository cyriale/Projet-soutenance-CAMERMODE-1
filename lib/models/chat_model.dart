
class ChatMessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isFromUser;
  final String? articleRefTitre;
  final String? articleRefImageUrl;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isFromUser,
    this.articleRefTitre,
    this.articleRefImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isFromUser': isFromUser,
      'articleRefTitre': articleRefTitre,
      'articleRefImageUrl': articleRefImageUrl,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.tryParse(map['timestamp']) ?? DateTime.now() : DateTime.now(),
      isFromUser: map['isFromUser'] ?? false,
      articleRefTitre: map['articleRefTitre'],
      articleRefImageUrl: map['articleRefImageUrl'],
    );
  }
}

class ConversationModel {
  final String id;
  final String prestataireId;
  final String prestataireNom;
  final String prestatairePhoto;
  final bool prestataireVerified;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? articleRefTitre;
  final String? articleRefImageUrl;

  ConversationModel({
    required this.id,
    required this.prestataireId,
    required this.prestataireNom,
    required this.prestatairePhoto,
    this.prestataireVerified = true,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.articleRefTitre,
    this.articleRefImageUrl,
  });
}
