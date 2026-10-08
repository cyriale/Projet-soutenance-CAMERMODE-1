
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'welcome_screen.dart';
import 'client/bottom_navigation_bar.dart';
import 'prestataire/bottom_navigation_bar.dart';
import 'admin/admin_main_screen.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/app_colors.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _forceClientMode = false;
  bool _isGuestMode = false;
  bool _hasSeenWelcome = false;

  void _toggleMode() {
    setState(() => _forceClientMode = !_forceClientMode);
  }

  void _enterGuestMode() {
    setState(() => _isGuestMode = true);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _authService.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.rose),
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint("⚠️ Erreur AuthWrapper: ${snapshot.error}");
        }

        UserModel? user = snapshot.data;

        // Si pas de compte et premier lancement -> Afficher la page de bienvenue
        if (user == null && !_isGuestMode && !_hasSeenWelcome) {
          return WelcomeScreen(
            onStarted: () => setState(() => _hasSeenWelcome = true),
          );
        }

        // Si pas de compte ET pas en mode visiteur -> Page Login
        if (user == null && !_isGuestMode) {
          return LoginScreen(onContinueAsGuest: _enterGuestMode);
        }

        // Si mode visiteur (user est null ici)
        if (_isGuestMode && user == null) {
          return ClientMainScreen(
            user: null,
            isPrestataire: false,
            onExitGuestMode: () => setState(() => _isGuestMode = false),
          );
        }

        // Vérification de compte bloqué
        if (user!.isBlocked) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.block, size: 70, color: Colors.red),
                    const SizedBox(height: 20),
                    const Text(
                      "Compte Suspendu",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.rejectionReason != null && user.rejectionReason!.isNotEmpty
                          ? "Motif : ${user.rejectionReason}"
                          : "Votre compte a été temporairement suspendu par un administrateur. Veuillez contacter le support.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: () => _authService.signOut(),
                      icon: const Icon(Icons.logout),
                      label: const Text("Se déconnecter"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Redirection Administrateur
        if (user.role == UserRole.admin) {
          return const AdminMainScreen();
        }

        // Logique de basculement pour le prestataire
        if (user.role == UserRole.prestataire && !_forceClientMode) {
          return PrestataireMainScreen(user: user, onSwitchMode: _toggleMode);
        } else {
          return ClientMainScreen(
            user: user,
            isPrestataire: user.role == UserRole.prestataire,
            onSwitchBack: user.role == UserRole.prestataire ? _toggleMode : null,
          );
        }
      },
    );
  }
}
