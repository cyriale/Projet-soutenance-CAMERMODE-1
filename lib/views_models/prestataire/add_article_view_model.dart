import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/article_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/permission_service.dart';
import '../../models/article_model.dart';

class AddArticleViewModel extends ChangeNotifier {
  final ArticleService _articleService = ArticleService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final PermissionService _permissionService = PermissionService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _imageFile;
  XFile? get imageFile => _imageFile;

  void setImageFile(XFile file) {
    _imageFile = file;
    notifyListeners();
  }

  final ImagePicker _picker = ImagePicker();

  Future<bool> pickImage(ImageSource source) async {
    bool hasPermission = true;
    if (source == ImageSource.camera) {
      hasPermission = await _permissionService.requestCameraPermission();
    } else {
      hasPermission = await _permissionService.requestPhotosPermission();
    }

    if (!hasPermission) return false;

    // Optimisation de l'image dès la capture (vitesse d'upload multipliée par 3)
    final picked = await _picker.pickImage(
      source: source, 
      imageQuality: 60, // Équilibre parfait qualité/poids
      maxWidth: 1080,   // Pas besoin de plus pour un dashboard mobile
      maxHeight: 1080,
    );
    if (picked != null) {
      _imageFile = picked;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> submitArticle({
    required String titre,
    required String description,
    required double prix,
    required ArticleType type,
    required String categorie,
    required List<String> tags,
    bool isPublished = true,
  }) async {
    if (_imageFile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Récupérer les infos du prestataire connecté
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        debugPrint("❌ Erreur : Aucun utilisateur connecté");
        return false;
      }

      // Récupération dynamique du profil
      final profile = await _userService.getUser(currentUser.uid);
      final nomPrestataire = (profile?.businessName != null && profile!.businessName!.isNotEmpty)
          ? profile.businessName!
          : "${profile?.prenom ?? ''} ${profile?.nom ?? 'Atelier'}".trim();
      final photoPrestataire = profile?.photoUrl ?? "";

      debugPrint("📦 Soumission de l'article par $nomPrestataire");

      final success = await _articleService.uploadArticle(
        prestataireId: currentUser.uid,
        prestataireNom: nomPrestataire.isNotEmpty ? nomPrestataire : "Atelier CamerMode",
        prestatairePhoto: photoPrestataire,
        prestataireAdresse: profile?.adresseActivite,
        prestationADomicile: profile?.isWorkingAtHome,
        imageFile: _imageFile!,
        titre: titre,
        description: description,
        prix: prix,
        type: type,
        categorie: categorie,
        tags: tags,
        isPublished: isPublished,
      );

      if (success) {
        debugPrint("✅ Article publié avec succès");
      } else {
        debugPrint("⚠️ Échec de la publication de l'article");
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint("❌ Exception submitArticle: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateArticle({
    required String articleId,
    required String titre,
    required String description,
    required double prix,
    required ArticleType type,
    required String categorie,
    required List<String> tags,
    required bool isPublished,
    required String currentImageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = _authService.currentUser;
      final success = await _articleService.updateArticle(
        articleId: articleId,
        titre: titre,
        description: description,
        prix: prix,
        type: type,
        categorie: categorie,
        tags: tags,
        isPublished: isPublished,
        newImageFile: _imageFile,
        currentImageUrl: currentImageUrl,
        prestataireId: currentUser?.uid,
      );

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint("Erreur updateArticle: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
