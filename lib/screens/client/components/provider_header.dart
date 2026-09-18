import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

/// Composant affichant l'en-tête du prestataire (Photo, Nom, Note, Adresse)
class ProviderHeader extends StatelessWidget {
  final String nom;
  final String photoUrl;
  final double rating;
  final int avisCount;
  final bool isVerified;
  final String adresse;
  final String distance;

  const ProviderHeader({
    super.key,
    required this.nom,
    required this.photoUrl,
    required this.rating,
    required this.avisCount,
    required this.isVerified,
    required this.adresse,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Photo de profil circulaire
              CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(photoUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom et Badge de vérification
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nom,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.noir),
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, color: Colors.blue, size: 20),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Note (Étoiles)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "$rating ($avisCount avis clients)",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Localisation et Distance
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.rose, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "$adresse • $distance",
                          style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
