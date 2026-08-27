
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "CamerMode",
          style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.noir),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recommandations personnalisées",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.noir),
            ),
            const SizedBox(height: 10),
            const Text("Basées sur votre style et vos mesures...", style: TextStyle(color: AppColors.texteSecondaire)),
            const SizedBox(height: 30),
            const Text(
              "Tendances",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.noir),
            ),
            const SizedBox(height: 16),
            // Futur emplacement des tendances
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0x1AFF50AF), // Rose with 10% opacity
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: Text("Articles suggérés bientôt disponibles")),
            ),
          ],
        ),
      ),
    );
  }
}
