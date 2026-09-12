import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/user_model.dart';
import 'prestataire_home_screen.dart';
import 'prestataire_explore_screen.dart';
import 'reservations_screen.dart';
import 'prestataire_messaging_screen.dart';
import 'prestataire_profile_screen.dart';

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
      const PrestataireExploreScreen(),
      const PrestataireReservationsScreen(),
      const PrestataireMessagingScreen(),
      PrestataireProfileScreen(user: widget.user, onSwitchMode: widget.onSwitchMode),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.rose,
        unselectedItemColor: const Color(0x991C1C1C),
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), activeIcon: Icon(Icons.search_rounded), label: 'Explorer'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'RDV'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), activeIcon: Icon(Icons.chat), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
