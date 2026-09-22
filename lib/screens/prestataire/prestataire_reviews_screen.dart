import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../models/review_model.dart';

class PrestataireReviewsScreen extends StatelessWidget {
  final String prestataireId;
  final String prestataireNom;

  const PrestataireReviewsScreen({
    super.key,
    required this.prestataireId,
    required this.prestataireNom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text(
          "Avis Clients",
          style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.noir),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('prestataireId', isEqualTo: prestataireId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.rose));
          }

          final docs = snapshot.data?.docs ?? [];
          final reviews = docs
              .map((doc) => ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          double avgRating = 0;
          if (reviews.isNotEmpty) {
            avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Synthèse des notes
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          reviews.isEmpty ? "5.0" : avgRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.noir),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            final filled = index < (reviews.isEmpty ? 5 : avgRating.round());
                            return Icon(
                              filled ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${reviews.length} avis reçus",
                          style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Réputation vérifiée",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.noir),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Les avis proviennent de clients ayant réalisé une commande ou un rendez-vous avec $prestataireNom.",
                            style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "DÉTAIL DES COMMENTAIRES",
                style: TextStyle(
                  color: AppColors.texteSecondaire,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),

              if (reviews.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      children: const [
                        Icon(Icons.star_outline, size: 48, color: Colors.amber),
                        SizedBox(height: 12),
                        Text(
                          "Aucun avis pour le moment",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.noir),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Les retours de vos clients apparaîtront ici dès qu'ils auront noté vos prestations.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.texteSecondaire, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...reviews.map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.rose.withOpacity(0.1),
                                backgroundImage: r.userPhoto != null && r.userPhoto!.isNotEmpty
                                    ? NetworkImage(r.userPhoto!)
                                    : null,
                                child: r.userPhoto == null || r.userPhoto!.isEmpty
                                    ? Text(
                                        r.userNom.isNotEmpty ? r.userNom[0].toUpperCase() : "C",
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.rose),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.userNom,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      r.serviceTitre,
                                      style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${r.rating.toStringAsFixed(1)}/5",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            r.commentaire.isNotEmpty ? r.commentaire : "Très satisfait de la prestation !",
                            style: const TextStyle(fontSize: 13, color: AppColors.noir, height: 1.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${r.createdAt.day.toString().padLeft(2, '0')}/${r.createdAt.month.toString().padLeft(2, '0')}/${r.createdAt.year}",
                            style: const TextStyle(fontSize: 11, color: AppColors.texteSecondaire),
                          ),
                        ],
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}
