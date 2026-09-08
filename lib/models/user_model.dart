
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { client, prestataire, admin }

enum VerificationStatus {
  enAttente,
  enCours,
  verifie,
  documentsACorriger,
  refuse,
  suspendu
}

class UserModel {
  final String uid;
  final String email;
  final String nom;
  final String prenom;
  final String? telephone;
  final UserRole role;
  final DateTime createdAt;
  final String? photoUrl;

  final double? taille; 
  final double? poids;
  final double? tourPoitrine;
  final double? tourTaille;
  final double? tourHanche;
  final double? largeurEpaules;
  final double? longueurBras;
  final double? longueurJambe;
  final String? morphologieType; // Ex: "Sablier", "V", "H"
  final bool hasBodyScan;
  final String? typeCheveux;
  final String? formeVisage;
  final bool hasFaceScan;

  final VerificationStatus? verificationStatus;
  final String? businessName;
  final String? businessType;
  final String? adresseActivite;
  final DateTime? dateNaissance;
  
  final String? idDocumentUrl;
  final String? idDocumentType;
  final String? idDocumentNumber;
  final String? professionalProofUrl;
  final String? shopProofUrl;
  final bool isWorkingAtHome;
  final String? selfieUrl;
  final String? rejectionReason;
  final bool isBlocked;

  UserModel({
    required this.uid,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.role,
    required this.createdAt,
    this.telephone,
    this.photoUrl,
    this.taille,
    this.poids,
    this.tourPoitrine,
    this.tourTaille,
    this.tourHanche,
    this.largeurEpaules,
    this.longueurBras,
    this.longueurJambe,
    this.morphologieType,
    this.hasBodyScan = false,
    this.typeCheveux,
    this.formeVisage,
    this.hasFaceScan = false,
    this.verificationStatus,
    this.businessName,
    this.businessType,
    this.adresseActivite,
    this.dateNaissance,
    this.idDocumentUrl,
    this.idDocumentType,
    this.idDocumentNumber,
    this.professionalProofUrl,
    this.shopProofUrl,
    this.isWorkingAtHome = false,
    this.selfieUrl,
    this.rejectionReason,
    this.isBlocked = false,
  });

  bool isVerified() => role == UserRole.prestataire && verificationStatus == VerificationStatus.verifie;

  String get roleLabel {
    switch (role) {
      case UserRole.admin: return "Administrateur";
      case UserRole.prestataire: return "Prestataire";
      case UserRole.client: return "Client";
    }
  }

  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      email: data['email'] ?? 'Sans email',
      nom: data['nom'] ?? 'Nom inconnu',
      prenom: data['prenom'] ?? '',
      telephone: data['telephone'],
      photoUrl: data['photoUrl'],
      role: _parseRole(data['role']),
      createdAt: _parseDate(data['createdAt']),
      taille: (data['taille'] as num?)?.toDouble(),
      poids: (data['poids'] as num?)?.toDouble(),
      tourPoitrine: (data['tourPoitrine'] as num?)?.toDouble(),
      tourTaille: (data['tourTaille'] as num?)?.toDouble(),
      tourHanche: (data['tourHanche'] as num?)?.toDouble(),
      largeurEpaules: (data['largeurEpaules'] as num?)?.toDouble(),
      longueurBras: (data['longueurBras'] as num?)?.toDouble(),
      longueurJambe: (data['longueurJambe'] as num?)?.toDouble(),
      morphologieType: data['morphologieType'],
      hasBodyScan: data['hasBodyScan'] ?? false,
      typeCheveux: data['typeCheveux'],
      formeVisage: data['formeVisage'],
      hasFaceScan: data['hasFaceScan'] ?? false,
      verificationStatus: _parseStatus(data['verificationStatus']),
      businessName: data['businessName'],
      businessType: data['businessType'],
      adresseActivite: data['adresseActivite'],
      dateNaissance: _parseDateNullable(data['dateNaissance']),
      idDocumentUrl: data['idDocumentUrl'],
      idDocumentType: data['idDocumentType'],
      idDocumentNumber: data['idDocumentNumber'],
      professionalProofUrl: data['professionalProofUrl'],
      shopProofUrl: data['shopProofUrl'],
      isWorkingAtHome: data['isWorkingAtHome'] ?? false,
      selfieUrl: data['selfieUrl'],
      rejectionReason: data['rejectionReason'],
      isBlocked: data['isBlocked'] ?? false,
    );
  }

  static UserRole _parseRole(dynamic role) {
    if (role == 'prestataire' || role == 'UserRole.prestataire') return UserRole.prestataire;
    if (role == 'admin' || role == 'UserRole.admin') return UserRole.admin;
    return UserRole.client;
  }

  static VerificationStatus? _parseStatus(dynamic status) {
    if (status == null) return null;
    final statusStr = status.toString().split('.').last;
    return VerificationStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusStr,
      orElse: () => VerificationStatus.enAttente,
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _parseDateNullable(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'photoUrl': photoUrl,
      'role': role.toString().split('.').last,
      'createdAt': createdAt,
      'taille': taille,
      'poids': poids,
      'tourPoitrine': tourPoitrine,
      'tourTaille': tourTaille,
      'tourHanche': tourHanche,
      'largeurEpaules': largeurEpaules,
      'longueurBras': longueurBras,
      'longueurJambe': longueurJambe,
      'morphologieType': morphologieType,
      'hasBodyScan': hasBodyScan,
      'typeCheveux': typeCheveux,
      'formeVisage': formeVisage,
      'hasFaceScan': hasFaceScan,
      'verificationStatus': verificationStatus?.toString().split('.').last,
      'businessName': businessName,
      'businessType': businessType,
      'adresseActivite': adresseActivite,
      'dateNaissance': dateNaissance,
      'idDocumentUrl': idDocumentUrl,
      'idDocumentType': idDocumentType,
      'idDocumentNumber': idDocumentNumber,
      'professionalProofUrl': professionalProofUrl,
      'shopProofUrl': shopProofUrl,
      'isWorkingAtHome': isWorkingAtHome,
      'selfieUrl': selfieUrl,
      'rejectionReason': rejectionReason,
      'isBlocked': isBlocked,
    };
  }
}
