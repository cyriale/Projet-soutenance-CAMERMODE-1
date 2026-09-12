
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/verification_service.dart';

class EditProfileViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final VerificationService _verificationService = VerificationService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _newProfileImage;
  XFile? get newProfileImage => _newProfileImage;

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      _newProfileImage = picked;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required UserModel user,
    required String nom,
    required String prenom,
    required String telephone,
    String? businessName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? photoUrl = user.photoUrl;

      // 1. Upload nouvelle photo si sélectionnée
      if (_newProfileImage != null) {
        photoUrl = await _verificationService.uploadDocument(
          userId: user.uid,
          file: _newProfileImage!,
          folderName: 'profile',
        );
      }

      // 2. Préparer les données
      Map<String, dynamic> data = {
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'photoUrl': photoUrl,
      };

      if (user.role == UserRole.prestataire) {
        data['businessName'] = businessName;
      }

      // 3. Sauvegarder dans Firestore
      final success = await _userService.updateUser(user.uid, data);
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
