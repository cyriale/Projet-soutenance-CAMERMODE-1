
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 🖤 Couleurs Principales (Mixte & Élégant)
  static const Color noir = Color(0xFF1C1C1C);       // Textes principaux, titres
  static const Color rose = Color(0xFFFF50AF);       // Boutons, icônes actives, marque
  static const Color roseClair = Color(0xFFFFF4FA);  // Arrière-plans, cartes légères
  
  // 🤍 Surfaces & Fond
  static const Color blanc = Color(0xFFFFFFFF);
  static const Color grisClair = Color(0xFFF5F5F5);

  // 🖤 Typographie & Détails
  static const Color textePrincipal = Color(0xFF1C1C1C);
  static const Color texteGris = Color(0xFF757575);
  static const Color texteSecondaire = Color(0x991C1C1C); // Noir avec opacité

  // 🛠 Utilitaires
  static const Color ligne = Color(0x1A1C1C1C);
  static const Color erreur = Color(0xFFB3261E);
  static const Color succes = Color(0xFF2E7D32);

  // 🌈 Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [rose, Color(0xFFFF85C1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
