
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Mes Réservations", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
      ),
      body: const Center(child: Text("Historique et réservations en cours")),
    );
  }
}
