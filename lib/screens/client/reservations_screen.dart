
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/reservation_model.dart';
import '../../services/reservation_service.dart';
import '../../services/auth_service.dart';
import 'leave_review_dialog.dart';

class ReservationsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ReservationsScreen({super.key, this.onBack});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReservationService _reservationService = ReservationService();
  final AuthService _authService = AuthService();

  final List<String> _statusFilters = [
    "Toutes",
    "En attente",
    "Confirmées",
    "Terminées",
    "Annulées",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.enAttente:
        return Colors.orange;
      case ReservationStatus.acceptee:
        return Colors.blue;
      case ReservationStatus.refusee:
        return AppColors.erreur;
      case ReservationStatus.annulee:
        return Colors.grey;
      case ReservationStatus.terminee:
        return AppColors.succes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.noir),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else if (widget.onBack != null) {
              widget.onBack!();
            }
          },
        ),
        title: const Text(
          "Mes Rendez-vous",
          style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.rose,
          unselectedLabelColor: AppColors.texteSecondaire,
          indicatorColor: AppColors.rose,
          indicatorWeight: 3,
          tabs: _statusFilters.map((s) => Tab(text: s)).toList(),
        ),
      ),
      body: StreamBuilder<List<ReservationModel>>(
        stream: _reservationService.getClientReservations(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.rose));
          }

          final allRes = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: _statusFilters.map((filter) {
              List<ReservationModel> currentList = allRes;
              if (filter == "En attente") {
                currentList = allRes.where((r) => r.status == ReservationStatus.enAttente).toList();
              } else if (filter == "Confirmées") {
                currentList = allRes.where((r) => r.status == ReservationStatus.acceptee).toList();
              } else if (filter == "Terminées") {
                currentList = allRes.where((r) => r.status == ReservationStatus.terminee).toList();
              } else if (filter == "Annulées") {
                currentList = allRes.where((r) => r.status == ReservationStatus.annulee || r.status == ReservationStatus.refusee).toList();
              }

              if (currentList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text("Aucune réservation ($filter)", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.noir)),
                      const SizedBox(height: 4),
                      const Text("Réservez une prestation depuis la page d'un article ou profil.", style: TextStyle(color: AppColors.texteSecondaire, fontSize: 12)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  final res = currentList[index];
                  final statusColor = _getStatusColor(res.status);

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: AppColors.ligne),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Statut & Prestataire
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  res.statusLabel.toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Text(
                                "${res.prixEstime.toInt()} FCFA",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.rose,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Infos Prestation
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (res.articleImageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    res.articleImageUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(Icons.cut, size: 40),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      res.serviceTitre,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.noir),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      res.prestataireNom,
                                      style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      res.lieuType == LieuPrestation.aDomicile ? "À votre domicile 🏠" : "Au salon : ${res.prestataireAdresse}",
                                      style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.ligne, height: 1),
                          const SizedBox(height: 12),

                          // Date & Heure
                          Row(
                            children: [
                              const Icon(Icons.event, color: AppColors.noir, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                "${res.date.day.toString().padLeft(2, '0')}/${res.date.month.toString().padLeft(2, '0')}/${res.date.year} à ${res.heure}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),

                          if (res.notes.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              "Note : ${res.notes}",
                              style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ],
                          const SizedBox(height: 14),

                          // Boutons d'Action selon le Statut
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Bouton Annuler si En attente ou Confirmée
                              if (res.status == ReservationStatus.enAttente || res.status == ReservationStatus.acceptee)
                                OutlinedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Annuler le rendez-vous ?"),
                                        content: const Text("Êtes-vous sûr de vouloir annuler cette demande de réservation ?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Non, conserver"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.erreur, foregroundColor: Colors.white),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _reservationService.updateReservationStatus(res.id, ReservationStatus.annulee);
                                            },
                                            child: const Text("Oui, annuler"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.erreur),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text("Annuler", style: TextStyle(color: AppColors.erreur, fontSize: 12)),
                                ),

                              // Bouton Évaluer / Avis UNIQUEMENT si Terminée (Section 14)
                              if (res.status == ReservationStatus.terminee)
                                ElevatedButton.icon(
                                  onPressed: res.hasReview
                                      ? null
                                      : () => LeaveReviewDialog.show(context, res),
                                  icon: const Icon(Icons.star, size: 16, color: Colors.white),
                                  label: Text(
                                    res.hasReview ? "Avis publié ✓" : "Laisser un avis vérifié",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: res.hasReview ? Colors.grey : Colors.amber[800],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
