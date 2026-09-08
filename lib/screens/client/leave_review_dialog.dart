
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/reservation_model.dart';
import '../../services/dashboard_service.dart';

class LeaveReviewDialog extends StatefulWidget {
  final ReservationModel reservation;

  const LeaveReviewDialog({super.key, required this.reservation});

  static Future<void> show(BuildContext context, ReservationModel reservation) {
    return showDialog(
      context: context,
      builder: (context) => LeaveReviewDialog(reservation: reservation),
    );
  }

  @override
  State<LeaveReviewDialog> createState() => _LeaveReviewDialogState();
}

class _LeaveReviewDialogState extends State<LeaveReviewDialog> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez saisir un commentaire pour votre évaluation."),
          backgroundColor: AppColors.erreur,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final service = DashboardService();
    service.addReview(
      reservationId: widget.reservation.id,
      prestataireId: widget.reservation.prestataireId,
      rating: _rating,
      commentaire: _commentController.text.trim(),
      serviceTitre: widget.reservation.serviceTitre,
      photoUrl: widget.reservation.articleImageUrl,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Merci ! Votre avis de client vérifié a été publié."),
          backgroundColor: AppColors.succes,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: Colors.amber, size: 36),
          ),
          const SizedBox(height: 12),
          const Text(
            "Évaluer la prestation",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.noir),
          ),
          const SizedBox(height: 4),
          Text(
            widget.reservation.serviceTitre,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.texteSecondaire),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge Prestation terminée vérifiée
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.verified, color: Colors.green, size: 14),
                  SizedBox(width: 6),
                  Text(
                    "Avis réservé aux prestations réalisées",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Étoiles de notation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starVal = index + 1.0;
                return IconButton(
                  icon: Icon(
                    _rating >= starVal ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _rating = starVal),
                );
              }),
            ),
            Text(
              "Note : ${_rating.toInt()} / 5 étoiles",
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.noir, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Champ commentaire
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Partagez votre expérience sur la qualité, l'accueil, la finition...",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.ligne)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler", style: TextStyle(color: AppColors.texteSecondaire)),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.rose,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Publier l'avis"),
        ),
      ],
    );
  }
}
