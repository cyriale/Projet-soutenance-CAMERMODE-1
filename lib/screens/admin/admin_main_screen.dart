
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../views_models/administrateur/admin_view_model.dart';
import 'admin_users_screen.dart';
import 'admin_verifications_screen.dart';
import 'admin_stats_screen.dart';
import 'admin_announcements_screen.dart';
import 'admin_content_review_screen.dart';
import '../../services/auth_service.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminStatsScreen(),
    const AdminUsersScreen(),
    const AdminVerificationsScreen(),
    const AdminContentReviewScreen(),
    const AdminAnnouncementsScreen(),
  ];

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.erreur),
            child: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminViewModel(),
      child: Scaffold(
        body: Row(
          children: [
            // Sidebar (Navigation Rail)
            NavigationRail(
              backgroundColor: AppColors.noir,
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              selectedIconTheme: const IconThemeData(color: AppColors.rose),
              unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
              selectedLabelTextStyle: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold),
              extended: MediaQuery.of(context).size.width > 900,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              leading: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: CircleAvatar(
                      backgroundColor: AppColors.rose,
                      child: const Text("A", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 900)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Chip(
                        label: Text("ADMIN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                ],
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text("Stats")),
                NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text("Utilisateurs")),
                NavigationRailDestination(icon: Icon(Icons.verified_user_outlined), selectedIcon: Icon(Icons.verified_user), label: Text("Vérifications")),
                NavigationRailDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library), label: Text("Galerie Globale")),
                NavigationRailDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: Text("Annonces")),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white70),
                      onPressed: () => _showLogoutDialog(context),
                      tooltip: "Déconnexion",
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Main Content
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
