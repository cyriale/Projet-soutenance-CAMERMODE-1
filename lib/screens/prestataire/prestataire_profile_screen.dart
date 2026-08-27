
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../common/account_security_screen.dart';
import '../../services/auth_service.dart';

class PrestataireProfileScreen extends StatelessWidget {
  final VoidCallback? onSwitchMode;
  const PrestataireProfileScreen({super.key, this.onSwitchMode});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Profil Professionnel", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (onSwitchMode != null)
            TextButton.icon(
              onPressed: onSwitchMode,
              icon: const Icon(Icons.swap_horiz, color: AppColors.rose),
              label: const Text("Mode Client", style: TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 30),
          _buildSectionTitle("MA VITRINE"),
          _buildProfileItem(Icons.business_center_outlined, "Informations professionnelles"),
          _buildProfileItem(Icons.inventory_2_outlined, "Gérer mes articles"),
          _buildProfileItem(Icons.calendar_today_outlined, "Gérer mes disponibilités"),
          _buildProfileItem(Icons.star_outline, "Consulter mes avis"),
          
          const SizedBox(height: 20),
          _buildSectionTitle("PARAMÈTRES"),
          _buildProfileItem(Icons.notifications_none, "Notifications"),
          _buildProfileItem(Icons.lock_outline, "Compte et sécurité", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSecurityScreen()));
          }),
          
          const SizedBox(height: 20),
          _buildProfileItem(Icons.logout, "Déconnexion", color: AppColors.erreur, onTap: () async {
            await authService.signOut();
          }),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: AppColors.rose, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.storefront, size: 50, color: AppColors.noir),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Ma Marque Mode", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.noir)),
          const Text("Coiffure & Tresses", style: TextStyle(color: AppColors.texteSecondaire)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.noir),
      title: Text(title, style: TextStyle(color: color ?? AppColors.noir, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.texteSecondaire),
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
