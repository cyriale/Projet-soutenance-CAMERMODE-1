
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Messagerie", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
      ),
      body: const Center(child: Text("Vos conversations avec les prestataires")),
    );
  }
}
