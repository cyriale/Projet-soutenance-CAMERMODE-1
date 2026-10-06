import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// ÉCRAN D'INTRODUCTION / ONBOARDING CLIENT
/// Présente le contenu, l'essayage IA, le scan morphologique et la réservation
/// avant d'accéder au Dashboard Client.
class ClientOnboardingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const ClientOnboardingScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  State<ClientOnboardingScreen> createState() => _ClientOnboardingScreenState();
}

class _ClientOnboardingScreenState extends State<ClientOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      "icon": Icons.checkroom_outlined,
      "badge": "BIENVENUE SUR CAMERMODE",
      "title": "L'Élégance Africaine à Votre Mesure",
      "description": "Découvrez la première plateforme camerounaise dédiée à la mode, au stylisme et aux créations traditionnelles (Wax, Ndop, Toghu) & modernes.",
      "color": AppColors.rose,
    },
    {
      "icon": Icons.auto_awesome,
      "badge": "INNOVATION IA NANO BANANA 2",
      "title": "Essayage Virtuel Vêtements & Coiffures",
      "description": "Jumelez votre photo avec n'importe quelle création. L'intelligence artificielle génère en direct votre rendu d'essayage sur-mesure !",
      "color": AppColors.rose,
    },
    {
      "icon": Icons.accessibility_new_rounded,
      "badge": "SCAN MORPHOLOGIQUE & VISAGE",
      "title": "Conseils Sur-Mesure de Notre Styliste",
      "description": "Analysez votre silhouette et la forme de votre visage via la caméra pour obtenir des recommandations d'habits et de coiffures adaptées à vos traits.",
      "color": AppColors.noir,
    },
    {
      "icon": Icons.storefront_outlined,
      "badge": "RÉSERVATION DIRECTE & ATELIERS",
      "title": "Prenez RDV chez Vos Créateurs Certifiés",
      "description": "Réservez vos prestations en salon ou à domicile et échangez en direct avec vos couturiers et salons de coiffure favoris.",
      "color": AppColors.rose,
    },
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onCompleted();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      body: SafeArea(
        child: Column(
          children: [
            // Barre supérieure : Bouton Ignorer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.blanc,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.checkroom, color: AppColors.rose, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "CAMERMODE",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.noir,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < _slides.length - 1)
                    TextButton(
                      onPressed: widget.onCompleted,
                      child: const Text(
                        "Ignorer",
                        style: TextStyle(
                          color: AppColors.texteGris,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Contenu des slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration icône
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.blanc,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (slide["color"] as Color).withOpacity(0.18),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            slide["icon"] as IconData,
                            size: 64,
                            color: slide["color"] as Color,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.blanc,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.rose.withOpacity(0.3)),
                          ),
                          child: Text(
                            slide["badge"] as String,
                            style: const TextStyle(
                              color: AppColors.rose,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Titre
                        Text(
                          slide["title"] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.noir,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Description
                        Text(
                          slide["description"] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.texteGris,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicateur de progression (Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.rose : AppColors.ligne,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Bouton Suivant / Commencer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rose,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == _slides.length - 1
                            ? "COMMENCER L'EXPÉRIENCE CAMERMODE"
                            : "CONTINUER",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentPage == _slides.length - 1
                            ? Icons.check_circle_outline
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
