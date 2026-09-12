import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/auth_wrapper.dart';
import 'core/app_colors.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Initialisation de base ultra-rapide
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialisation Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Lancer les services en arrière-plan (SANS BLOQUER LE RENDU)
  _initBackgroundServices();

  // 4. Affichage IMMÉDIAT de l'application
  runApp(const MyApp());
}

// Fonction pour charger les services sans faire attendre l'utilisateur
void _initBackgroundServices() {
  // Initialisation des notifications (Seulement sur Mobile)
  NotificationService().initialize();
  
  // Configuration Firestore (Vitesse optimisée)
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (e) {
    debugPrint("Firestore Settings: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CamerMode',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.rose,
          primary: AppColors.rose,
          surface: AppColors.roseClair,
        ),
        useMaterial3: true,
      ),
      // Le AuthWrapper gère la redirection vers Login ou Dashboards
      home: const AuthWrapper(),
    );
  }
}
