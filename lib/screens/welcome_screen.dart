import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onStarted;
  const WelcomeScreen({super.key, required this.onStarted});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: AppColors.roseClair, // Utilisation du fond clair de l'appli
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dashboards/pattern_bg.png'), // Si vous avez un motif, sinon on peut l'enlever
            opacity: 0.05,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 40,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    // LOGO CENTRAL
                    Hero(
                      tag: 'logo',
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.rose.withValues(alpha: 0.15),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: isSmallScreen ? 180 : 240,
                            width: isSmallScreen ? 180 : 240,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 140,
                                height: 140,
                                decoration: const BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.checkroom, size: 70, color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // TITRE - Toujours en Or pour le côté Royal
                    const Text(
                      "CAMERMODE",
                      style: TextStyle(
                        color: AppColors.noir,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // SLOGAN
                    const Text(
                      "L'élégance africaine à votre mesure",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.texteSecondaire,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // BADGES FONCTIONNALITÉS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFeatureBadge(Icons.auto_awesome, "Styliste IA"),
                        const SizedBox(width: 10),
                        _buildFeatureBadge(Icons.view_in_ar, "Essai 3D"),
                      ],
                    ),

                    const Spacer(),
                    const SizedBox(height: 32),
                    
                    // BOUTON COMMENCER
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: onStarted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rose,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "DÉCOUVRIR CAMERMODE",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    const Text(
                      "Mode Camerounaise • Coiffure • Stylisme Digital",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.texteSecondaire, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildFeatureBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.rose),
          const SizedBox(width: 6),
          Text(
            label, 
            style: const TextStyle(
              color: AppColors.noir, 
              fontSize: 12, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }
}
