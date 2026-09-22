import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/user_model.dart';
import 'prestataire_home_screen.dart';
import 'reservations_screen.dart';
import 'prestataire_messaging_screen.dart';
import 'prestataire_profile_screen.dart';
import 'add_article_screen.dart';

class PrestataireMainScreen extends StatefulWidget {
  final UserModel user;
  final VoidCallback? onSwitchMode;
  
  const PrestataireMainScreen({
    super.key, 
    required this.user,
    this.onSwitchMode,
  });

  @override
  State<PrestataireMainScreen> createState() => _PrestataireMainScreenState();
}

class _PrestataireMainScreenState extends State<PrestataireMainScreen> {
  int _selectedIndex = 0;

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppColors.rose : AppColors.texteSecondaire,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? AppColors.rose : AppColors.texteSecondaire,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      PrestataireHomeScreen(user: widget.user),
      const PrestataireMessagingScreen(),
      const SizedBox(), // Dummy pour alignement de l'index central
      const PrestataireReservationsScreen(),
      PrestataireProfileScreen(user: widget.user, onSwitchMode: widget.onSwitchMode),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddArticleScreen()),
          );
        },
        backgroundColor: AppColors.rose,
        elevation: 4,
        shape: const CircleBorder(),
        tooltip: "Ajouter une création",
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 8,
        padding: EdgeInsets.zero,
        height: 64,
        child: Row(
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Accueil',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'Messages',
            ),
            const SizedBox(width: 56), // Espace central réservé au FAB
            _buildNavItem(
              index: 3,
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month,
              label: 'RDV',
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
