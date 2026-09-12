import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/article_service.dart';
import '../../services/reservation_service.dart';
import '../../services/auth_service.dart';
import '../../models/reservation_model.dart';
import '../../models/user_model.dart';
import '../auth/prestataire_registration_stepper.dart';

class PrestataireHomeScreen extends StatelessWidget {
  final UserModel? user;
  const PrestataireHomeScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final articleService = ArticleService();
    final resService = ReservationService();
    final uid = user?.uid ?? auth.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.businessName != null && user!.businessName!.isNotEmpty
                  ? user!.businessName!
                  : "Tableau de bord",
              style: const TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (user != null)
              Text(
                "Espace Prestataire • ${user!.businessType ?? 'Mode'}",
                style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 12),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bannière de statut de vérification interactive
            if (user != null) ...[
              _buildVerificationStatusBanner(context, user!),
              const SizedBox(height: 24),
            ],

            const Text("Aperçu de votre activité", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context, 
                    "Articles créés", 
                    articleService.getPrestataireArticles(uid),
                    Icons.inventory_2,
                    Colors.blue,
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
                    filter: (List<ReservationModel> list) => list.where((r) => r.status == ReservationStatus.enAttente).length,
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.rose));
                }
                final res = snapshot.data ?? [];
                if (res.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        "Aucune réservation pour le moment. Vos demandes apparaîtront ici.",
                        style: TextStyle(color: AppColors.texteSecondaire, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: res.take(4).map((r) => Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(r.serviceTitre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Le ${r.date.day}/${r.date.month}/${r.date.year} à ${r.heure}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 10, color: _getStatusColor(r.status)),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusLabel(r.status),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getStatusColor(r.status)),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStatusBanner(BuildContext context, UserModel u) {
    if (u.verificationStatus == VerificationStatus.verifie) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              child: const Icon(Icons.verified, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Atelier Vérifié & Certifié ✅", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
                  SizedBox(height: 2),
                  Text("Votre profil et vos créations sont pleinement visibles par tous les clients.", style: TextStyle(fontSize: 12, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (u.verificationStatus == VerificationStatus.documentsACorriger) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade400, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Correction demandée par l'administrateur",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Motif : ${u.rejectionReason ?? 'Veuillez mettre à jour vos justificatifs ou pièces d\'identité.'}",
              style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PrestataireRegistrationStepper(existingUser: u)),
                  );
                },
                icon: const Icon(Icons.edit_document, size: 18, color: Colors.white),
                label: const Text("CORRIGER ET METTRE À JOUR MON DOSSIER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ],
        ),
      );
    }

    if (u.verificationStatus == VerificationStatus.refuse) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cancel, color: Colors.red, size: 24),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text("Dossier non validé", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text("Motif : ${u.rejectionReason ?? 'Votre demande d\'inscription a été refusée.'}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrestataireRegistrationStepper(existingUser: u)),
                );
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
              child: const Text("SOUMETTRE UN NOUVEAU DOSSIER"),
            ),
          ],
        ),
      );
    }

    // Par défaut : En attente
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                child: const Icon(Icons.hourglass_top, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Dossier en cours de vérification par l'admin",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Votre inscription a bien été enregistrée ! Vous avez accès à votre tableau de bord pour publier vos créations et préparer votre atelier. Vos articles seront visibles publiquement dès validation par l'administration.",
            style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
          ),
        ],
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
      },
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

  String _getStatusLabel(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.enAttente: return "En attente";
      case ReservationStatus.acceptee: return "Confirmé";
      case ReservationStatus.terminee: return "Terminé";
      default: return "Annulé";
    }
  }
}
