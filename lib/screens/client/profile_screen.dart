import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../complete_profile_screen.dart';
import '../common/account_security_screen.dart';
import '../common/notification_settings_sheet.dart';
import 'become_prestataire_screen.dart';
import 'favorites_screen.dart';
import 'saved_images_screen.dart';
import '../../models/article_model.dart';
import '../common/edit_profile_screen.dart';
import 'body_scan_screen.dart';
import 'face_scan_screen.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../compronents/app_cached_image.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel? user;
  final bool isPrestataire;
  final VoidCallback? onSwitchBack;
  final VoidCallback? onBack;
  
  const ProfileScreen({
    super.key, 
    this.user,
    this.isPrestataire = false, 
    this.onSwitchBack,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final dashboardService = DashboardService();

    return ListenableBuilder(
      listenable: dashboardService,
      builder: (context, _) {
        final savedTryOns = dashboardService.savedTryOns;
        final myReviews = dashboardService.reviews;

        return Scaffold(
          backgroundColor: AppColors.roseClair,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.noir),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else if (onBack != null) {
                  onBack!();
                }
              },
            ),
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
              // Header Profil Dynamique
              _buildProfileHeader(context, dashboardService),
              const SizedBox(height: 24),

              // Section Activité & Mode Dynamique
              _buildSectionTitle("MON UNIVERS MODE & BEAUTÉ"),
              _buildProfileItem(
                Icons.bookmark_border,
                "Mes Favoris",
                badge: "${dashboardService.articles.where((a) => a.isFavorite).length}",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen())),
              ),
              _buildProfileItem(
                Icons.collections_bookmark_outlined,
                "Mes Sauvegardes d'images (Moodboard)",
                badge: "${dashboardService.savedArticleIds.length}",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedImagesScreen())),
              ),
              _buildProfileItem(
                Icons.auto_awesome,
                "Mes Essayages Virtuels sauvegardés",
                badge: "${savedTryOns.length}",
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Mes Essayages Enregistrés", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.noir)),
                              Text("${savedTryOns.length} sauvegardé(s)", style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (savedTryOns.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Center(child: Text("Aucun essayage enregistré pour le moment.", style: TextStyle(color: AppColors.texteGris))),
                            )
                          else
                            SizedBox(
                              height: 300,
                              child: ListView.separated(
                                itemCount: savedTryOns.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final t = savedTryOns[index];
                                  final String imgUrl = t['imageUrl'] ?? "";
                                  final Uint8List? aiResultBytes = t['aiResultBytes'];

                                  return InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      _showTryOnDetailDialog(context, t);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: AppCachedImage(
                                              imageUrl: imgUrl,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.arrow_forward, size: 14, color: AppColors.texteGris),
                                          const SizedBox(width: 6),
                                          if (aiResultBytes != null)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.memory(
                                                aiResultBytes,
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: AppColors.rose.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.auto_awesome, size: 18, color: AppColors.rose),
                                            ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(t['articleTitre'] ?? "Essayage", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                Text("Couleur : ${t['colorName']} • Taille : ${t['size']}", style: const TextStyle(fontSize: 11, color: AppColors.texteGris)),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.visibility, color: AppColors.rose, size: 18),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              _buildProfileItem(
                Icons.straighten,
                "Mensurations & Morphologie",
                badge: user?.morphologieType ?? "Non définie",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CompleteProfileScreen(type: ArticleType.couture)),
                ),
              ),
              _buildProfileItem(
                Icons.accessibility_new,
                "Scan Morphologique Corporel (Caméra IA)",
                badge: user?.hasBodyScan == true ? "Fait ✅" : "À faire",
                color: user?.hasBodyScan == true ? Colors.green : AppColors.rose,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BodyScanScreen()),
                ),
              ),
              _buildProfileItem(
                Icons.face_retouching_natural,
                "Scan Visage & Forme Coiffure (IA Visage)",
                badge: user?.hasFaceScan == true ? "Fait ✅" : "À faire",
                color: user?.hasFaceScan == true ? Colors.green : Colors.purple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FaceScanScreen()),
                ),
              ),
              _buildProfileItem(
                Icons.star_outline,
                "Mes Avis de client vérifié",
                badge: "${myReviews.length}",
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Mes Avis Clients Vérifiés", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.noir)),
                          const SizedBox(height: 12),
                          if (myReviews.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: Text("Aucun avis publié pour le moment.")),
                            )
                          else
                            ...myReviews.map((r) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(r.serviceTitre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text(r.commentaire, style: const TextStyle(fontSize: 12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  Text("${r.rating.toInt()}/5", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              _buildSectionTitle("SÉCURITÉ & CONFIDENTIALITÉ"),
              _buildProfileItem(
                Icons.notifications_none,
                "Notifications & Alertes",
                onTap: () => NotificationSettingsSheet.show(context, isPrestataire: isPrestataire),
              ),
              _buildProfileItem(
                Icons.lock_outline,
                "Compte et protection des données",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSecurityScreen())),
              ),
              _buildProfileItem(
                Icons.privacy_tip_outlined,
                "Confidentialité des photos & localisation",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text("Charte de Confidentialité"),
                      content: const Text(
                        "• Vos photos d'essayage personnel restent privées sur votre appareil et ne sont jamais rendues publiques.\n\n"
                        "• Votre localisation exacte n'est partagée qu'avec votre accord pour calculer la distance aux ateliers et salons.\n\n"
                        "• Aucun intermédiaire de paiement bancaire n'est requis par l'application.",
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Compris")),
                      ],
                    ),
                  );
                },
              ),
              
              if (!isPrestataire) ...[
                const SizedBox(height: 20),
                _buildSectionTitle("PROFESSIONNEL"),
                _buildProfileItem(
                  Icons.storefront,
                  "Devenir prestataire certifié",
                  color: AppColors.rose,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BecomePrestataireScreen())),
                ),
              ],

              const SizedBox(height: 20),
              _buildProfileItem(
                Icons.logout,
                "Déconnexion",
                color: AppColors.erreur,
                onTap: () => _showLogoutDialog(context, authService),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Êtes-vous sûr de vouloir quitter votre session ?"),
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

  Widget _buildProfileHeader(BuildContext context, DashboardService service) {
    if (user == null) {
      return Center(
        child: Column(
          children: [
            const CircleAvatar(
              radius: 46,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_outline, size: 48, color: AppColors.rose),
            ),
            const SizedBox(height: 12),
            const Text(
              "Mode Visiteur",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.noir),
            ),
            const SizedBox(height: 4),
            const Text(
              "Inscrivez-vous pour personnaliser votre expérience",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.texteSecondaire, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final ImageProvider? avatarImageProvider = user!.photoUrl != null && user!.photoUrl!.isNotEmpty
        ? (user!.photoUrl!.startsWith("http")
            ? NetworkImage(user!.photoUrl!)
            : FileImage(File(user!.photoUrl!)) as ImageProvider)
        : null;

    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: Colors.white,
              backgroundImage: avatarImageProvider,
              child: avatarImageProvider == null
                  ? Text(
                      user!.nom.isNotEmpty ? user!.nom[0].toUpperCase() : "U",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.rose),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${user!.prenom} ${user!.nom}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.noir),
          ),
          const SizedBox(height: 2),
          Text(
            user!.email,
            style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 13),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => EditProfileScreen(user: user!))
            ),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text("Modifier le profil", style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.rose,
              side: const BorderSide(color: AppColors.rose),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.rose.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Morphologie : ${user!.morphologieType ?? 'Non définie'}",
              style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, {Color? color, String? badge, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.noir, size: 22),
        title: Text(title, style: TextStyle(color: color ?? AppColors.noir, fontWeight: FontWeight.w500, fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.rose.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge, style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.texteSecondaire),
          ],
        ),
        onTap: onTap ?? () {},
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    );
  }

  void _showTryOnDetailDialog(BuildContext context, Map<String, dynamic> t) {
    final String articleImgUrl = t['imageUrl'] ?? "";
    final Uint8List? aiResultBytes = t['aiResultBytes'];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      t['articleTitre'] ?? "Détail de l'essayage",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Couleur : ${t['colorName']} • Taille : ${t['size']}",
                style: const TextStyle(color: AppColors.texteGris, fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Text("Article & Résultat de l'IA :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 10),
              SizedBox(
                height: 280,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Article", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AppCachedImage(imageUrl: articleImgUrl, fit: BoxFit.cover, width: double.infinity),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Résultat IA", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: aiResultBytes != null
                                  ? Image.memory(aiResultBytes, fit: BoxFit.cover, width: double.infinity)
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Text("Aucun rendu IA", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text("Fermer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rose,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
