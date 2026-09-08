
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../views_models/administrateur/admin_view_model.dart';

class AdminStatsScreen extends StatelessWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Tableau de Bord"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.noir, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Aperçu de la plateforme", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildStatCard("Utilisateurs", viewModel.stats['totalUsers']?.toString() ?? "0", Icons.people),
                _buildStatCard("Clients", viewModel.stats['totalClients']?.toString() ?? "0", Icons.person),
                _buildStatCard("Prestataires", viewModel.stats['totalPrestataires']?.toString() ?? "0", Icons.business),
                _buildStatCard("Articles", viewModel.stats['totalArticles']?.toString() ?? "0", Icons.inventory_2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.rose, size: 32),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.texteSecondaire)),
        ],
      ),
    );
  }
}
