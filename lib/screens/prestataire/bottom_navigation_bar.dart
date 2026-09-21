import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/user_model.dart';
import 'prestataire_home_screen.dart';
import 'prestataire_explore_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      PrestataireHomeScreen(user: widget.user),
      const PrestataireMessagingScreen(),
      const SizedBox(), // Dummy pour le bouton central
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
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 2) return; // Ne rien faire pour l'index central dummy
            setState(() => _selectedIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.rose,
          unselectedItemColor: const Color(0x991C1C1C),
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), activeIcon: Icon(Icons.chat), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.add, color: Colors.transparent), label: ''), 
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'RDV'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
