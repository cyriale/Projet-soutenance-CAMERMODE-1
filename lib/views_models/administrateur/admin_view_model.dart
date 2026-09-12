import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/admin_service.dart';
import '../../services/verification_service.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  final VerificationService _verificationService = VerificationService();

  List<UserModel> _allUsers = [];
  List<UserModel> get allUsers => _allUsers;

  List<UserModel> get allPrestataires => _allUsers
      .where((u) => u.role == UserRole.prestataire)
      .toList();

  List<UserModel> get pendingPrestataires => _allUsers
      .where((u) => u.role == UserRole.prestataire && 
             (u.verificationStatus == null ||
              u.verificationStatus == VerificationStatus.enAttente || 
              u.verificationStatus == VerificationStatus.enCours))
      .toList();

  List<UserModel> get correctionRequestedPrestataires => _allUsers
      .where((u) => u.role == UserRole.prestataire && 
              u.verificationStatus == VerificationStatus.documentsACorriger)
      .toList();

  List<UserModel> get verifiedPrestataires => _allUsers
      .where((u) => u.role == UserRole.prestataire && 
              u.verificationStatus == VerificationStatus.verifie)
      .toList();

  List<UserModel> get rejectedPrestataires => _allUsers
      .where((u) => u.role == UserRole.prestataire && 
              u.verificationStatus == VerificationStatus.refuse)
      .toList();

  Map<String, int> _stats = {};
  Map<String, int> get stats => _stats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AdminViewModel() {
    _init();
  }

  void _init() {
    debugPrint("🚀 Initialisation du Dashboard Admin...");
    _adminService.getAllUsers().listen((users) {
      debugPrint("📥 Données reçues : ${users.length} utilisateurs trouvés.");
      _allUsers = users;
      fetchStats();
      notifyListeners();
    }, onError: (error) {
      debugPrint("❌ ERREUR FIRESTORE : $error");
    });
  }

  Future<void> fetchStats() async {
    _stats = await _adminService.getGlobalStats();
    notifyListeners();
  }

  Future<void> toggleBlockUser(String uid, bool block) async {
    await _adminService.toggleBlockUser(uid, block);
  }

  Future<void> deleteUser(String uid) async {
    await _adminService.deleteUser(uid);
  }

  Future<void> verifyPrestataire(String uid, VerificationStatus status, {String? reason}) async {
    await _verificationService.updateStatus(uid, status, reason: reason);
    fetchStats();
    notifyListeners();
  }

  Future<void> sendAnnouncement(String title, String content) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _adminService.sendAnnouncement(title, content);
    } catch (e) {
      debugPrint("❌ Erreur lors de l'envoi de l'annonce : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
