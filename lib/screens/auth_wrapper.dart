
import 'package:flutter/material.dart';
import 'login_screen.dart';
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

  void _toggleMode() {
    setState(() => _forceClientMode = !_forceClientMode);
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

        if (user == null) {
          return const LoginScreen();
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
