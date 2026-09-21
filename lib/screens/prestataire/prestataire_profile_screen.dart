
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../common/account_security_screen.dart';
import '../common/edit_profile_screen.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'add_article_screen.dart';
import 'prestataire_articles_screen.dart';

class PrestataireProfileScreen extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onSwitchMode;
  const PrestataireProfileScreen({super.key, required this.user, this.onSwitchMode});

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
          _buildProfileHeader(context),
          const SizedBox(height: 30),
          _buildSectionTitle("MA VITRINE"),
          _buildProfileItem(
            Icons.add_a_photo_outlined, 
            "Ajouter une création",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddArticleScreen())),
          ),
          _buildProfileItem(Icons.business_center_outlined, "Informations professionnelles"),
          _buildProfileItem(
            Icons.inventory_2_outlined, 
            "Gérer mes articles",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrestataireArticlesScreen())),
          ),
          _buildProfileItem(Icons.calendar_today_outlined, "Gérer mes disponibilités"),
          _buildProfileItem(Icons.star_outline, "Consulter mes avis"),
          
          const SizedBox(height: 20),
          _buildSectionTitle("PARAMÈTRES"),
          _buildProfileItem(Icons.notifications_none, "Notifications"),
          _buildProfileItem(Icons.lock_outline, "Compte et sécurité", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSecurityScreen()));
          }),
          
          const SizedBox(height: 20),
          _buildProfileItem(Icons.logout, "Déconnexion", color: AppColors.erreur, onTap: () => _showLogoutDialog(context, authService)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter de votre compte professionnel ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.erreur),
            child: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: AppColors.rose, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null || user.photoUrl!.isEmpty
                  ? const Icon(Icons.storefront, size: 50, color: AppColors.noir)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.businessName ?? "${user.prenom} ${user.nom}", 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.noir)
          ),
          Text(
            user.businessType ?? "Prestataire Mode", 
            style: const TextStyle(color: AppColors.texteSecondaire)
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => EditProfileScreen(user: user))
            ),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text("Modifier les infos", style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.rose,
              side: const BorderSide(color: AppColors.rose),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
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
