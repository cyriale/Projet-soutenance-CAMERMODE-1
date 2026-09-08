
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/article_service.dart';
import '../../services/reservation_service.dart';
import '../../services/auth_service.dart';
import '../../models/reservation_model.dart';

class PrestataireHomeScreen extends StatelessWidget {
  const PrestataireHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final articleService = ArticleService();
    final resService = ReservationService();
    final uid = auth.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Tableau de bord", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Aperçu de votre activité", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context, 
                    "Articles", 
                    articleService.getPrestataireArticles(uid),
                    Icons.inventory_2,
                    Colors.blue
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context, 
                    "RDV en attente", 
                    resService.getPrestataireReservations(uid),
                    Icons.pending_actions,
                    Colors.orange,
                    filter: (List<ReservationModel> list) => list.where((r) => r.status == ReservationStatus.enAttente).length
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            const Text("Dernières réservations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            StreamBuilder<List<ReservationModel>>(
              stream: resService.getPrestataireReservations(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final res = snapshot.data ?? [];
                if (res.isEmpty) return const Text("Aucune réservation reçue.");
                
                return Column(
                  children: res.take(3).map((r) => Card(
                    child: ListTile(
                      title: Text(r.serviceTitre),
                      subtitle: Text("Le ${r.date.day}/${r.date.month} à ${r.heure}"),
                      trailing: Icon(Icons.circle, size: 12, color: _getStatusColor(r.status)),
                    ),
                  )).toList(),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard<T>(
    BuildContext context, 
    String label, 
    Stream<List<T>> stream, 
    IconData icon, 
    Color color,
    {int Function(List<T>)? filter}
  ) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.hasData 
            ? (filter != null ? filter(snapshot.data!) : snapshot.data!.length)
            : 0;
            
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 12),
              Text("$count", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 12)),
            ],
          ),
        );
      }
    );
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.enAttente: return Colors.orange;
      case ReservationStatus.acceptee: return Colors.blue;
      case ReservationStatus.terminee: return Colors.green;
      default: return Colors.grey;
    }
  }
}
