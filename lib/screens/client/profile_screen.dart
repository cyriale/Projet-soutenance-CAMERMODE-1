
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../complete_profile_screen.dart';
import '../common/account_security_screen.dart';
import 'become_prestataire_screen.dart';
import '../../models/article_model.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  final bool isPrestataire;
  final VoidCallback? onSwitchBack;
  
  const ProfileScreen({
    super.key, 
    this.isPrestataire = false,
    this.onSwitchBack,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Mon Profil", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isPrestataire && onSwitchBack != null)
            TextButton.icon(
              onPressed: onSwitchBack,
              icon: const Icon(Icons.business_center, color: AppColors.rose),
              label: const Text("Mode Pro", style: TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 30),
          _buildSectionTitle("MON ACTIVITÉ"),
          _buildProfileItem(Icons.person_outline, "Informations personnelles"),
          _buildProfileItem(Icons.tune, "Préférences"),
          _buildProfileItem(Icons.favorite_border, "Favoris"),
          _buildProfileItem(Icons.straighten, "Mensurations", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CompleteProfileScreen(type: ArticleType.couture)));
          }),
          _buildProfileItem(Icons.star_outline, "Mes avis"),
          _buildProfileItem(Icons.notifications_none, "Notifications"),
          
          const SizedBox(height: 20),
          _buildSectionTitle("SÉCURITÉ & SUPPORT"),
          _buildProfileItem(Icons.lock_outline, "Compte et sécurité", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSecurityScreen()));
          }),
          _buildProfileItem(Icons.flag_outlined, "Signaler un prestataire"),
          
          if (!isPrestataire) ...[
            const SizedBox(height: 20),
            _buildSectionTitle("PROFESSIONNEL"),
            _buildProfileItem(Icons.storefront, "Devenir prestataire", color: AppColors.rose, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BecomePrestataireScreen()));
            }),
          ],

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
              child: Icon(Icons.person, size: 50, color: AppColors.noir),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Test User", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.noir)),
          const Text("test@camermode.com", style: TextStyle(color: AppColors.texteSecondaire)),
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
