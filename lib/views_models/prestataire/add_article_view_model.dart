
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/article_service.dart';
import '../../services/auth_service.dart';
import '../../models/article_model.dart';

class AddArticleViewModel extends ChangeNotifier {
  final ArticleService _articleService = ArticleService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _imageFile;
  XFile? get imageFile => _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      _imageFile = picked;
      notifyListeners();
    }
  }

  Future<bool> submitArticle({
    required String titre,
    required String description,
    required double prix,
    required ArticleType type,
    required String categorie,
    required List<String> tags,
  }) async {
    if (_imageFile == null) return false;

    _isLoading = true;
    notifyListeners();

    // Récupérer les infos du prestataire connecté
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    // Simulation/Récupération du profil complet (pour le nom/photo du prestataire)
    // Idéalement on passerait par le UserService pour avoir les vraies infos
    final success = await _articleService.uploadArticle(
      prestataireId: currentUser.uid,
      prestataireNom: "Mon Atelier", // À dynamiser avec le vrai nom du profil
      prestatairePhoto: "", // À dynamiser
      imageFile: _imageFile!,
      titre: titre,
      description: description,
      prix: prix,
      type: type,
      categorie: categorie,
      tags: tags,
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }
}
