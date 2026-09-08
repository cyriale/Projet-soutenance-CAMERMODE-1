
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/reservation_model.dart';
import '../../services/reservation_service.dart';
import '../../services/auth_service.dart';

class PrestataireReservationsScreen extends StatefulWidget {
  const PrestataireReservationsScreen({super.key});

  @override
  State<PrestataireReservationsScreen> createState() => _PrestataireReservationsScreenState();
}

class _PrestataireReservationsScreenState extends State<PrestataireReservationsScreen> {
  final ReservationService _reservationService = ReservationService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final prestataireId = _authService.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Mes Rendez-vous Clients", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<ReservationModel>>(
        stream: _reservationService.getPrestataireReservations(prestataireId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.rose));
          }

          final reservations = snapshot.data ?? [];

          if (reservations.isEmpty) {
            return const Center(
              child: Text("Aucun rendez-vous pour le moment."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final res = reservations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(res.serviceTitre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          _buildStatusBadge(res.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Date : ${res.date.day}/${res.date.month}/${res.date.year} à ${res.heure}"),
                      Text("Lieu : ${res.lieuType == LieuPrestation.aDomicile ? 'À domicile (${res.adresseClient})' : 'Au salon'}"),
                      if (res.attachedMeasurements != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.rose.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.straighten, size: 16, color: AppColors.rose),
                                  SizedBox(width: 8),
                                  Text("Mesures 3D jointes :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.rose)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 16,
                                children: [
                                  _measureText("Poitrine", res.attachedMeasurements!['tourPoitrine']),
                                  _measureText("Taille", res.attachedMeasurements!['tourTaille']),
                                  _measureText("Hanche", res.attachedMeasurements!['tourHanche']),
                                  _measureText("Épaules", res.attachedMeasurements!['largeurEpaules']),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (res.status == ReservationStatus.enAttente)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _reservationService.updateReservationStatus(res.id, ReservationStatus.refusee),
                                child: const Text("REFUSER", style: TextStyle(color: Colors.red)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _reservationService.updateReservationStatus(res.id, ReservationStatus.acceptee),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text("ACCEPTER", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      if (res.status == ReservationStatus.acceptee)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _reservationService.updateReservationStatus(res.id, ReservationStatus.terminee),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose),
                            child: const Text("MARQUER COMME TERMINÉ", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(ReservationStatus status) {
    Color color = Colors.grey;
    String label = status.name;

    switch (status) {
      case ReservationStatus.enAttente:
        color = Colors.orange;
        label = "EN ATTENTE";
        break;
      case ReservationStatus.acceptee:
        color = Colors.blue;
        label = "CONFIRMÉ";
        break;
      case ReservationStatus.terminee:
        color = Colors.green;
        label = "TERMINÉ";
        break;
      case ReservationStatus.refusee:
      case ReservationStatus.annulee:
        color = Colors.red;
        label = "ANNULÉ/REFUSÉ";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _measureText(String label, double? value) {
    return Text("$label: ${value?.toStringAsFixed(1)}cm", style: const TextStyle(fontSize: 12));
  }
}
