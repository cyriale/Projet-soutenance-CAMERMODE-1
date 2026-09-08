
enum ReservationStatus {
  enAttente,
  acceptee,
  refusee,
  annulee,
  terminee,
}

enum LieuPrestation {
  auSalon,
  aDomicile,
}

class ReservationModel {
  final String id;
  final String userId;
  final String prestataireId;
  final String prestataireNom;
  final String prestatairePhoto;
  final String prestataireAdresse;
  final String serviceTitre;
  final String? articleImageUrl;
  final DateTime date;
  final String heure;
  final LieuPrestation lieuType;
  final String adresseClient;
  final String notes;
  final ReservationStatus status;
  final double prixEstime;
  final bool hasReview;
  final Map<String, double>? attachedMeasurements;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.prestataireId,
    required this.prestataireNom,
    this.prestatairePhoto = '',
    this.prestataireAdresse = '',
    required this.serviceTitre,
    this.articleImageUrl,
    required this.date,
    required this.heure,
    this.lieuType = LieuPrestation.auSalon,
    this.adresseClient = '',
    this.notes = '',
    this.status = ReservationStatus.enAttente,
    this.prixEstime = 0.0,
    this.hasReview = false,
    this.attachedMeasurements,
  });

  String get statusLabel {
    switch (status) {
      case ReservationStatus.enAttente:
        return "En attente";
      case ReservationStatus.acceptee:
        return "Confirmée";
      case ReservationStatus.refusee:
        return "Refusée";
      case ReservationStatus.annulee:
        return "Annulée";
      case ReservationStatus.terminee:
        return "Terminée";
    }
  }

  ReservationModel copyWith({
    String? id,
    String? userId,
    String? prestataireId,
    String? prestataireNom,
    String? prestatairePhoto,
    String? prestataireAdresse,
    String? serviceTitre,
    String? articleImageUrl,
    DateTime? date,
    String? heure,
    LieuPrestation? lieuType,
    String? adresseClient,
    String? notes,
    ReservationStatus? status,
    double? prixEstime,
    bool? hasReview,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      prestataireId: prestataireId ?? this.prestataireId,
      prestataireNom: prestataireNom ?? this.prestataireNom,
      prestatairePhoto: prestatairePhoto ?? this.prestatairePhoto,
      prestataireAdresse: prestataireAdresse ?? this.prestataireAdresse,
      serviceTitre: serviceTitre ?? this.serviceTitre,
      articleImageUrl: articleImageUrl ?? this.articleImageUrl,
      date: date ?? this.date,
      heure: heure ?? this.heure,
      lieuType: lieuType ?? this.lieuType,
      adresseClient: adresseClient ?? this.adresseClient,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      prixEstime: prixEstime ?? this.prixEstime,
      hasReview: hasReview ?? this.hasReview,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'prestataireId': prestataireId,
      'prestataireNom': prestataireNom,
      'prestatairePhoto': prestatairePhoto,
      'prestataireAdresse': prestataireAdresse,
      'serviceTitre': serviceTitre,
      'articleImageUrl': articleImageUrl,
      'date': date.toIso8601String(),
      'heure': heure,
      'lieuType': lieuType.name,
      'adresseClient': adresseClient,
      'notes': notes,
      'status': status.name,
      'prixEstime': prixEstime,
      'hasReview': hasReview,
      'attachedMeasurements': attachedMeasurements,
    };
  }

  factory ReservationModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReservationModel(
      id: docId,
      userId: map['userId'] ?? '',
      prestataireId: map['prestataireId'] ?? '',
      prestataireNom: map['prestataireNom'] ?? 'Prestataire',
      prestatairePhoto: map['prestatairePhoto'] ?? '',
      prestataireAdresse: map['prestataireAdresse'] ?? '',
      serviceTitre: map['serviceTitre'] ?? 'Prestation',
      articleImageUrl: map['articleImageUrl'],
      date: map['date'] != null ? DateTime.tryParse(map['date']) ?? DateTime.now() : DateTime.now(),
      heure: map['heure'] ?? '10:00',
      lieuType: map['lieuType'] == 'aDomicile' ? LieuPrestation.aDomicile : LieuPrestation.auSalon,
      adresseClient: map['adresseClient'] ?? '',
      notes: map['notes'] ?? '',
      status: _parseStatus(map['status']),
      prixEstime: (map['prixEstime'] as num?)?.toDouble() ?? 0.0,
      hasReview: map['hasReview'] ?? false,
      attachedMeasurements: map['attachedMeasurements'] != null 
          ? Map<String, double>.from(map['attachedMeasurements'].map((k, v) => MapEntry(k, (v as num).toDouble())))
          : null,
    );
  }

  static ReservationStatus _parseStatus(String? status) {
    switch (status) {
      case 'acceptee':
        return ReservationStatus.acceptee;
      case 'refusee':
        return ReservationStatus.refusee;
      case 'annulee':
        return ReservationStatus.annulee;
      case 'terminee':
        return ReservationStatus.terminee;
      default:
        return ReservationStatus.enAttente;
    }
  }
}
