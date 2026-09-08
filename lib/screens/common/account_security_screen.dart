
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../compronents/app_button.dart';
import '../auth/role_selection_screen.dart';

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Compte et sécurité", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.noir),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSecurityItem("Modifier les informations du compte"),
          _buildSecurityItem("Modifier le mot de passe"),
          const Divider(height: 40),
          const Text(
            "Besoin d'un autre profil ?",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.noir),
          ),
          const SizedBox(height: 8),
          const Text(
            "Vous pouvez créer un nouveau compte indépendant (Client ou Prestataire) avec une adresse e-mail différente.",
            style: TextStyle(color: AppColors.texteSecondaire, fontSize: 14),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: "CRÉER UN NOUVEAU COMPTE",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RoleSelectionScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(String title) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {},
      contentPadding: EdgeInsets.zero,
    );
  }
}
