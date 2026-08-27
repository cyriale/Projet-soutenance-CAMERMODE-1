
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class PrestataireArticlesScreen extends StatelessWidget {
  const PrestataireArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Mes Articles", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add, color: AppColors.rose)),
        ],
      ),
      body: const Center(
        child: Text("Gérez vos coiffures et vêtements ici."),
      ),
    );
  }
}
