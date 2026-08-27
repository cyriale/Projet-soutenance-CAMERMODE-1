
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../models/user_model.dart';
import 'prestataire_home_screen.dart';
import 'prestataire_explore_screen.dart';
import 'reservations_screen.dart';
import 'prestataire_messaging_screen.dart';
import 'prestataire_profile_screen.dart';

class PrestataireMainScreen extends StatefulWidget {
  final VoidCallback? onSwitchMode;
  const PrestataireMainScreen({super.key, this.onSwitchMode});

  @override
  State<PrestataireMainScreen> createState() => _PrestataireMainScreenState();
}

class _PrestataireMainScreenState extends State<PrestataireMainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        
        UserModel user = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);

        // Si le prestataire n'est pas vérifié, on affiche un message d'attente
        if (user.verificationStatus != VerificationStatus.verifie) {
          return _buildPendingVerificationUI(user);
        }

        final List<Widget> pages = [
          const PrestataireHomeScreen(),
          const PrestataireExploreScreen(),
          const PrestataireReservationsScreen(),
          const PrestataireMessagingScreen(),
          PrestataireProfileScreen(onSwitchMode: widget.onSwitchMode),
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
      },
    );
  }

  Widget _buildPendingVerificationUI(UserModel user) {
    String message = "Votre dossier est en cours d'examen.";
    IconData icon = Icons.hourglass_top;
    Color color = AppColors.rose;

    if (user.verificationStatus == VerificationStatus.documentsACorriger) {
      message = "Certains documents doivent être corrigés : \n${user.rejectionReason ?? ''}";
      icon = Icons.error_outline;
      color = AppColors.erreur;
    } else if (user.verificationStatus == VerificationStatus.refuse) {
      message = "Désolé, votre demande a été refusée.";
      icon = Icons.cancel_outlined;
      color = AppColors.erreur;
    }

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: color),
            const SizedBox(height: 32),
            const Text(
              "Vérification en cours",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 16),
            ),
            const SizedBox(height: 48),
            if (user.verificationStatus == VerificationStatus.documentsACorriger)
              ElevatedButton(
                onPressed: () {
                  // Rediriger vers la modification des documents
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose, minimumSize: const Size(double.infinity, 56)),
                child: const Text("CORRIGER MON DOSSIER"),
              ),
            TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text("Se déconnecter", style: TextStyle(color: AppColors.erreur)),
            ),
          ],
        ),
      ),
    );
  }
}
