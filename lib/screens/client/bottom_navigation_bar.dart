
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/user_model.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'favorites_screen.dart';
import 'reservations_screen.dart';
import 'messaging_screen.dart';
import 'profile_screen.dart';

class ClientMainScreen extends StatefulWidget {
  final UserModel? user;
  final bool isPrestataire;
  final VoidCallback? onSwitchBack;
  final VoidCallback? onExitGuestMode;

  const ClientMainScreen({
    super.key, 
    this.user,
    this.isPrestataire = false, 
    this.onSwitchBack,
    this.onExitGuestMode,
  });

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  int _selectedIndex = 0;

  void _goToHome() {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(onExitGuestMode: widget.onExitGuestMode),
      ExploreScreen(onBack: _goToHome),
      FavoritesScreen(onBack: _goToHome),
      ReservationsScreen(onBack: _goToHome),
      MessagingScreen(onBack: _goToHome),
      ProfileScreen(
        user: widget.user,
        isPrestataire: widget.isPrestataire,
        onSwitchBack: widget.onSwitchBack,
        onBack: _goToHome,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            // Si c'est un visiteur (user null) et qu'il clique ailleurs que sur Accueil ou Explorer
            if (widget.user == null && index > 1) {
              if (widget.onExitGuestMode != null) {
                widget.onExitGuestMode!();
              }
              return;
            }
            setState(() => _selectedIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.rose,
          unselectedItemColor: AppColors.texteSecondaire,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search_rounded),
              label: 'Explorer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favoris',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Réservations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
