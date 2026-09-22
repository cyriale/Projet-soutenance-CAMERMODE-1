
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'welcome_screen.dart';
import 'client/bottom_navigation_bar.dart';
import 'prestataire/bottom_navigation_bar.dart';
import 'admin/admin_main_screen.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
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
    final authService = AuthService();

    return StreamBuilder<UserModel?>(
      stream: authService.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.pink)));
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

        // Si mode visiteur (user est forcément null ici)
        if (_isGuestMode && user == null) {
          return ClientMainScreen(
            user: null,
            isPrestataire: false,
            onExitGuestMode: () => setState(() => _isGuestMode = false),
          );
        }

        // Redirection Administrateur
        if (user!.role == UserRole.admin) {
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
