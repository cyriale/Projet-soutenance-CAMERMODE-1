
enum ArticleType { coiffure, couture }

class ArticleModel {
  final String id;
  final String prestataireId;
  final String prestataireNom;
  final String prestatairePhoto;
  final double prestataireRating;
  final int prestataireAvisCount;
  final bool prestataireVerified;
  final String prestataireAdresse;
  final String prestataireDistance;
  final bool prestationADomicile;
  final String titre;
  final String description;
  final double prix;
  final String imageUrl;
  final List<String> galleryImages;
  final ArticleType type;
  final String categorie;
  final List<String> couleursDisponibles;
  final List<String> taillesDisponibles;
  final Map<String, dynamic>? specs;
  final int likesCount;
  final bool isLiked;
  final bool isFavorite;
  final bool isSaved;
  final bool isPrestation;
  final List<String> tags;
  final String? tryOnOverlayUrl;
  final bool isPublished;

  ArticleModel({
    required this.id,
    required this.prestataireId,
    this.prestataireNom = "Atelier d'Élégance",
    this.prestatairePhoto = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80",
    this.prestataireRating = 4.8,
    this.prestataireAvisCount = 34,
    this.prestataireVerified = true,
    this.prestataireAdresse = "Akwa, Douala",
    this.prestataireDistance = "2.3 km",
    this.prestationADomicile = true,
    required this.titre,
    required this.description,
    required this.prix,
    required this.imageUrl,
    this.galleryImages = const [],
    required this.type,
    this.categorie = "Mode Africaine",
    this.couleursDisponibles = const ["Noir", "Bleu", "Rouge", "Vert", "Jaune", "Or"],
    this.taillesDisponibles = const ["S", "M", "L", "XL", "Sur-mesure"],
    this.specs,
    this.likesCount = 0,
    this.isLiked = false,
    this.isFavorite = false,
    this.isSaved = false,
    this.isPrestation = false,
    this.tags = const [],
    this.tryOnOverlayUrl,
    this.isPublished = true,
  });

  ArticleModel copyWith({
    String? id,
    String? prestataireId,
    String? prestataireNom,
    String? prestatairePhoto,
    double? prestataireRating,
    int? prestataireAvisCount,
    bool? prestataireVerified,
    String? prestataireAdresse,
    String? prestataireDistance,
    bool? prestationADomicile,
    String? titre,
    String? description,
    double? prix,
    String? imageUrl,
    List<String>? galleryImages,
    ArticleType? type,
    String? categorie,
    List<String>? couleursDisponibles,
    List<String>? taillesDisponibles,
    Map<String, dynamic>? specs,
    int? likesCount,
    bool? isLiked,
    bool? isFavorite,
    bool? isSaved,
    bool? isPrestation,
    List<String>? tags,
    String? tryOnOverlayUrl,
    bool? isPublished,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      prestataireId: prestataireId ?? this.prestataireId,
      prestataireNom: prestataireNom ?? this.prestataireNom,
      prestatairePhoto: prestatairePhoto ?? this.prestatairePhoto,
      prestataireRating: prestataireRating ?? this.prestataireRating,
      prestataireAvisCount: prestataireAvisCount ?? this.prestataireAvisCount,
      prestataireVerified: prestataireVerified ?? this.prestataireVerified,
      prestataireAdresse: prestataireAdresse ?? this.prestataireAdresse,
      prestataireDistance: prestataireDistance ?? this.prestataireDistance,
      prestationADomicile: prestationADomicile ?? this.prestationADomicile,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      type: type ?? this.type,
      categorie: categorie ?? this.categorie,
      couleursDisponibles: couleursDisponibles ?? this.couleursDisponibles,
      taillesDisponibles: taillesDisponibles ?? this.taillesDisponibles,
      specs: specs ?? this.specs,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      isFavorite: isFavorite ?? this.isFavorite,
      isSaved: isSaved ?? this.isSaved,
      isPrestation: isPrestation ?? this.isPrestation,
      tags: tags ?? this.tags,
      tryOnOverlayUrl: tryOnOverlayUrl ?? this.tryOnOverlayUrl,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prestataireId': prestataireId,
      'prestataireNom': prestataireNom,
      'prestatairePhoto': prestatairePhoto,
      'prestataireRating': prestataireRating,
      'prestataireAvisCount': prestataireAvisCount,
      'prestataireVerified': prestataireVerified,
      'prestataireAdresse': prestataireAdresse,
      'prestataireDistance': prestataireDistance,
      'prestationADomicile': prestationADomicile,
      'titre': titre,
      'description': description,
      'prix': prix,
      'imageUrl': imageUrl,
      'galleryImages': galleryImages,
      'type': type.name,
      'categorie': categorie,
      'couleursDisponibles': couleursDisponibles,
      'taillesDisponibles': taillesDisponibles,
      'specs': specs,
      'likesCount': likesCount,
      'isPrestation': isPrestation,
      'tags': tags,
      'tryOnOverlayUrl': tryOnOverlayUrl,
      'isPublished': isPublished,
    };
  }

  factory ArticleModel.fromMap(Map<String, dynamic> map, String docId) {
    return ArticleModel(
      id: docId,
      prestataireId: map['prestataireId'] ?? '',
      prestataireNom: map['prestataireNom'] ?? 'Prestataire CAMERMODE',
      prestatairePhoto: map['prestatairePhoto'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      prestataireRating: (map['prestataireRating'] as num?)?.toDouble() ?? 4.8,
      prestataireAvisCount: (map['prestataireAvisCount'] as num?)?.toInt() ?? 10,
      prestataireVerified: map['prestataireVerified'] ?? true,
      prestataireAdresse: map['prestataireAdresse'] ?? 'Douala, Cameroun',
      prestataireDistance: map['prestataireDistance'] ?? '2.5 km',
      prestationADomicile: map['prestationADomicile'] ?? false,
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      prix: (map['prix'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? map['image_url'] ?? '', 
      galleryImages: List<String>.from(map['galleryImages'] ?? []),
      type: map['type'] == 'coiffure' ? ArticleType.coiffure : ArticleType.couture,
      categorie: map['categorie'] ?? 'Mode',
      couleursDisponibles: List<String>.from(map['couleursDisponibles'] ?? ["Noir", "Blanc"]),
      taillesDisponibles: List<String>.from(map['taillesDisponibles'] ?? ["S", "M", "L"]),
      specs: map['specs'] != null ? Map<String, dynamic>.from(map['specs']) : null,
      likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
      isLiked: map['isLiked'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
      isSaved: map['isSaved'] ?? false,
      isPrestation: map['isPrestation'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      tryOnOverlayUrl: map['tryOnOverlayUrl'],
      isPublished: map['isPublished'] ?? true,
    );
  }
}
