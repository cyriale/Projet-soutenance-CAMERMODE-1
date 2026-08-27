
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../signup_screen.dart';
import 'prestataire_registration_stepper.dart';
import '../../models/user_model.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Que souhaitez-vous faire ?',
              style: TextStyle(
                color: AppColors.noir,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildRoleCard(
              context,
              title: 'Client',
              subtitle: 'Je veux découvrir des styles et faire des essayages 3D.',
              icon: Icons.person_outline,
              role: UserRole.client,
            ),
            const SizedBox(height: 20),
            _buildRoleCard(
              context,
              title: 'Prestataire',
              subtitle: 'Je suis couturier ou coiffeur et je veux proposer mes services.',
              icon: Icons.content_cut,
              role: UserRole.prestataire,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required UserRole role,
  }) {
    return GestureDetector(
      onTap: () {
        if (role == UserRole.prestataire) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrestataireRegistrationStepper()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignupScreen(selectedRole: role)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.rose.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.noir.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.roseClair,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.rose, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.noir,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.rose),
          ],
        ),
      ),
    );
  }
}
