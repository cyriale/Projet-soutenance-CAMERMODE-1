
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

  // --- Profil Client ---
  final double? taille; 
  final double? poids;
  final double? tourPoitrine;
  final double? tourTaille;
  final double? tourHanche;
  final bool hasBodyScan;
  final String? typeCheveux;
  final String? formeVisage;
  final bool hasFaceScan;

  // --- Profil Prestataire & Vérification ---
  final VerificationStatus? verificationStatus;
  final String? businessName;
  final String? businessType; // 'Couture' or 'Coiffure'
  final String? adresseActivite;
  final DateTime? dateNaissance;
  
  // Documents (URLs vers Firebase Storage)
  final String? idDocumentUrl;
  final String? idDocumentType; // 'CNI', 'Passeport', etc.
  final String? idDocumentNumber;
  final String? professionalProofUrl;
  final String? shopProofUrl; // Photo boutique ou attestation
  final bool isWorkingAtHome;
  final String? selfieUrl;
  final String? rejectionReason;

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
  });

  bool isVerified() => role == UserRole.prestataire && verificationStatus == VerificationStatus.verifie;

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      email: data['email'] ?? '',
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      telephone: data['telephone'],
      photoUrl: data['photoUrl'],
      role: _parseRole(data['role']),
      createdAt: (data['createdAt'] != null) ? (data['createdAt'] as dynamic).toDate() : DateTime.now(),
      taille: data['taille']?.toDouble(),
      poids: data['poids']?.toDouble(),
      tourPoitrine: data['tourPoitrine']?.toDouble(),
      tourTaille: data['tourTaille']?.toDouble(),
      tourHanche: data['tourHanche']?.toDouble(),
      hasBodyScan: data['hasBodyScan'] ?? false,
      typeCheveux: data['typeCheveux'],
      formeVisage: data['formeVisage'],
      hasFaceScan: data['hasFaceScan'] ?? false,
      verificationStatus: _parseStatus(data['verificationStatus']),
      businessName: data['businessName'],
      businessType: data['businessType'],
      adresseActivite: data['adresseActivite'],
      dateNaissance: (data['dateNaissance'] != null) ? (data['dateNaissance'] as dynamic).toDate() : null,
      idDocumentUrl: data['idDocumentUrl'],
      idDocumentType: data['idDocumentType'],
      idDocumentNumber: data['idDocumentNumber'],
      professionalProofUrl: data['professionalProofUrl'],
      shopProofUrl: data['shopProofUrl'],
      isWorkingAtHome: data['isWorkingAtHome'] ?? false,
      selfieUrl: data['selfieUrl'],
      rejectionReason: data['rejectionReason'],
    );
  }

  static UserRole _parseRole(String? role) {
    if (role == 'prestataire') return UserRole.prestataire;
    if (role == 'admin') return UserRole.admin;
    return UserRole.client;
  }

  static VerificationStatus? _parseStatus(String? status) {
    if (status == null) return null;
    return VerificationStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => VerificationStatus.enAttente,
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
    };
  }
}
