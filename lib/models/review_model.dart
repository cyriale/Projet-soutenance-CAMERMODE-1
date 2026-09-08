
class ReviewModel {
  final String id;
  final String reservationId;
  final String prestataireId;
  final String userId;
  final String userNom;
  final String? userPhoto;
  final double rating;
  final String commentaire;
  final DateTime createdAt;
  final String serviceTitre;
  final String? photoUrl;

  ReviewModel({
    required this.id,
    required this.reservationId,
    required this.prestataireId,
    required this.userId,
    required this.userNom,
    this.userPhoto,
    required this.rating,
    required this.commentaire,
    required this.createdAt,
    required this.serviceTitre,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reservationId': reservationId,
      'prestataireId': prestataireId,
      'userId': userId,
      'userNom': userNom,
      'userPhoto': userPhoto,
      'rating': rating,
      'commentaire': commentaire,
      'createdAt': createdAt.toIso8601String(),
      'serviceTitre': serviceTitre,
      'photoUrl': photoUrl,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReviewModel(
      id: docId,
      reservationId: map['reservationId'] ?? '',
      prestataireId: map['prestataireId'] ?? '',
      userId: map['userId'] ?? '',
      userNom: map['userNom'] ?? 'Client vérifié',
      userPhoto: map['userPhoto'],
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      commentaire: map['commentaire'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) ?? DateTime.now() : DateTime.now(),
      serviceTitre: map['serviceTitre'] ?? 'Prestation',
      photoUrl: map['photoUrl'],
    );
  }
}
