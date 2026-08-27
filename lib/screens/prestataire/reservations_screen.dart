
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class PrestataireReservationsScreen extends StatelessWidget {
  const PrestataireReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("RDV Clients", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Text("Suivez vos rendez-vous."),
      ),
    );
  }
}
