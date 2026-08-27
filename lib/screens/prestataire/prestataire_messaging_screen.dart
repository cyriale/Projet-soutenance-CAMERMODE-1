
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class PrestataireMessagingScreen extends StatelessWidget {
  const PrestataireMessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Messages Clients", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Text("Discutez avec vos clients."),
      ),
    );
  }
}
