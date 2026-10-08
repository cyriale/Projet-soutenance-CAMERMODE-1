
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
  final double? latitude;
  final double? longitude;
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
    this.latitude,
    this.longitude,
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
  bool get isVerifiedUser => role == UserRole.prestataire && verificationStatus == VerificationStatus.verifie;
  bool get isPendingVerification => role == UserRole.prestataire && (verificationStatus == null || verificationStatus == VerificationStatus.enAttente || verificationStatus == VerificationStatus.enCours);
  bool get isCorrectionNeeded => role == UserRole.prestataire && verificationStatus == VerificationStatus.documentsACorriger;
  bool get isRejected => role == UserRole.prestataire && verificationStatus == VerificationStatus.refuse;

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
      email: data['email']?.toString().trim() ?? 'Sans email',
      nom: data['nom']?.toString().trim() ?? 'Nom inconnu',
      prenom: data['prenom']?.toString().trim() ?? '',
      telephone: data['telephone']?.toString(),
      photoUrl: data['photoUrl']?.toString(),
      role: _parseRole(data['role']),
      createdAt: _parseDate(data['createdAt']),
      taille: _parseDouble(data['taille']),
      poids: _parseDouble(data['poids']),
      tourPoitrine: _parseDouble(data['tourPoitrine']),
      tourTaille: _parseDouble(data['tourTaille']),
      tourHanche: _parseDouble(data['tourHanche']),
      largeurEpaules: _parseDouble(data['largeurEpaules']),
      longueurBras: _parseDouble(data['longueurBras']),
      longueurJambe: _parseDouble(data['longueurJambe']),
      morphologieType: data['morphologieType']?.toString(),
      hasBodyScan: _parseBool(data['hasBodyScan']),
      typeCheveux: data['typeCheveux']?.toString(),
      formeVisage: data['formeVisage']?.toString(),
      hasFaceScan: _parseBool(data['hasFaceScan']),
      verificationStatus: _parseStatus(data['verificationStatus']),
      businessName: data['businessName']?.toString(),
      businessType: data['businessType']?.toString(),
      adresseActivite: data['adresseActivite']?.toString(),
      latitude: _parseDouble(data['latitude']),
      longitude: _parseDouble(data['longitude']),
      dateNaissance: _parseDateNullable(data['dateNaissance']),
      idDocumentUrl: data['idDocumentUrl']?.toString(),
      idDocumentType: data['idDocumentType']?.toString(),
      idDocumentNumber: data['idDocumentNumber']?.toString(),
      professionalProofUrl: data['professionalProofUrl']?.toString(),
      shopProofUrl: data['shopProofUrl']?.toString(),
      isWorkingAtHome: _parseBool(data['isWorkingAtHome']),
      selfieUrl: data['selfieUrl']?.toString(),
      rejectionReason: data['rejectionReason']?.toString(),
      isBlocked: _parseBool(data['isBlocked']),
    );
  }

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val.trim().replaceAll(',', '.'));
    }
    return null;
  }

  static bool _parseBool(dynamic val, {bool defaultValue = false}) {
    if (val == null) return defaultValue;
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final s = val.trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'oui' || s == 'yes';
    }
    return defaultValue;
  }

  static UserRole _parseRole(dynamic role) {
    if (role == null) return UserRole.client;
    String roleStr = role.toString().toLowerCase().trim();
    if (roleStr.contains('admin')) return UserRole.admin;
    if (roleStr.contains('prestataire') ||
        roleStr.contains('coutur') ||
        roleStr.contains('coiff') ||
        roleStr.contains('tailor') ||
        roleStr.contains('vendeur') ||
        roleStr.contains('provider') ||
        roleStr.contains('artisan')) {
      return UserRole.prestataire;
    }
    return UserRole.client;
  }

  static VerificationStatus? _parseStatus(dynamic status) {
    if (status == null) return null;
    final statusStr = status.toString().split('.').last.toLowerCase().trim();
    if (statusStr.contains('verif') || statusStr.contains('valid') || statusStr.contains('approve')) {
      return VerificationStatus.verifie;
    }
    if (statusStr.contains('cours') || statusStr.contains('progress')) {
      return VerificationStatus.enCours;
    }
    if (statusStr.contains('corriger') || statusStr.contains('correct') || statusStr.contains('doc')) {
      return VerificationStatus.documentsACorriger;
    }
    if (statusStr.contains('refus') || statusStr.contains('reject')) {
      return VerificationStatus.refuse;
    }
    if (statusStr.contains('suspend')) {
      return VerificationStatus.suspendu;
    }
    return VerificationStatus.enAttente;
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _parseDateNullable(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    if (date is String) {
      DateTime? parsed = DateTime.tryParse(date);
      if (parsed != null) return parsed;
      // Format JJ/MM/AAAA ou JJ-MM-AAAA
      final parts = date.split(RegExp(r'[/.-]'));
      if (parts.length == 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (d != null && m != null && y != null) {
          if (y > 1000) return DateTime(y, m, d);
          if (d > 1000) return DateTime(d, m, y);
        }
      }
    }
    return null;
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? nom,
    String? prenom,
    String? telephone,
    UserRole? role,
    DateTime? createdAt,
    String? photoUrl,
    double? taille,
    double? poids,
    double? tourPoitrine,
    double? tourTaille,
    double? tourHanche,
    double? largeurEpaules,
    double? longueurBras,
    double? longueurJambe,
    String? morphologieType,
    bool? hasBodyScan,
    String? typeCheveux,
    String? formeVisage,
    bool? hasFaceScan,
    VerificationStatus? verificationStatus,
    String? businessName,
    String? businessType,
    String? adresseActivite,
    double? latitude,
    double? longitude,
    DateTime? dateNaissance,
    String? idDocumentUrl,
    String? idDocumentType,
    String? idDocumentNumber,
    String? professionalProofUrl,
    String? shopProofUrl,
    bool? isWorkingAtHome,
    String? selfieUrl,
    String? rejectionReason,
    bool? isBlocked,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
      taille: taille ?? this.taille,
      poids: poids ?? this.poids,
      tourPoitrine: tourPoitrine ?? this.tourPoitrine,
      tourTaille: tourTaille ?? this.tourTaille,
      tourHanche: tourHanche ?? this.tourHanche,
      largeurEpaules: largeurEpaules ?? this.largeurEpaules,
      longueurBras: longueurBras ?? this.longueurBras,
      longueurJambe: longueurJambe ?? this.longueurJambe,
      morphologieType: morphologieType ?? this.morphologieType,
      hasBodyScan: hasBodyScan ?? this.hasBodyScan,
      typeCheveux: typeCheveux ?? this.typeCheveux,
      formeVisage: formeVisage ?? this.formeVisage,
      hasFaceScan: hasFaceScan ?? this.hasFaceScan,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      adresseActivite: adresseActivite ?? this.adresseActivite,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      idDocumentType: idDocumentType ?? this.idDocumentType,
      idDocumentNumber: idDocumentNumber ?? this.idDocumentNumber,
      professionalProofUrl: professionalProofUrl ?? this.professionalProofUrl,
      shopProofUrl: shopProofUrl ?? this.shopProofUrl,
      isWorkingAtHome: isWorkingAtHome ?? this.isWorkingAtHome,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isBlocked: isBlocked ?? this.isBlocked,
    );
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
      'latitude': latitude,
      'longitude': longitude,
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
