import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_wrapper.dart';
import 'core/app_colors.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';
import 'firebase_options.dart'; // Import important

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase initialisé avec succès");
    
    // Tentative de création
    await _setupAdminAccount();
  } catch (e) {
    debugPrint("❌ Erreur d'initialisation Firebase : $e");
  }
  
  runApp(const MyApp());
}

Future<void> _setupAdminAccount() async {
  try {
    final authService = AuthService();
    final result = await authService.signUp(
      email: 'cyrialesahamene@gmail.com',
      password: '12345678',
      nom: "Admin",
      prenom: "CamerMode",
      role: UserRole.admin,
    );
    
    if (result == null) {
      debugPrint("✅ Compte Admin créé ou déjà existant.");
    } else {
      debugPrint("ℹ️ Info Admin : $result");
    }
  } catch (e) {
    debugPrint("⚠️ Erreur lors de la création de l'admin : $e");
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
          onPrimary: Colors.white,
          surface: AppColors.roseClair,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.roseClair,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.noir),
          titleTextStyle: TextStyle(
            color: AppColors.noir,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.noir),
          bodyMedium: TextStyle(color: AppColors.noir),
          displayLarge: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
