
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/article_model.dart';

class ProviderLocationDialog extends StatelessWidget {
  final ArticleModel article;

  const ProviderLocationDialog({super.key, required this.article});

  static void show(BuildContext context, ArticleModel article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProviderLocationDialog(article: article),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on, color: Colors.blue, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Localisation du prestataire",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.noir,
                      ),
                    ),
                    Text(
                      article.prestataireNom,
                      style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Carte Visuelle Stylisée (Simulée avec repères géographiques réels)
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.ligne),
              image: const DecorationImage(
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.rose,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                          ],
                        ),
                        child: const Icon(Icons.storefront, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          article.prestataireNom,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.noir),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Distance : ${article.prestataireDistance}",
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Adresse & Détails
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.roseClair,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.pin_drop, color: AppColors.rose, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Adresse de l'atelier / salon",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.texteSecondaire),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            article.prestataireAdresse,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.noir),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: AppColors.ligne, height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      article.prestationADomicile ? Icons.home_repair_service : Icons.store,
                      color: article.prestationADomicile ? AppColors.succes : AppColors.texteSecondaire,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        article.prestationADomicile
                            ? "Prestation à domicile disponible sur demande"
                            : "Prestation uniquement en boutique / salon",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: article.prestationADomicile ? AppColors.succes : AppColors.texteSecondaire,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Note confidentialité
          Row(
            children: const [
              Icon(Icons.shield_outlined, size: 16, color: AppColors.texteSecondaire),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Seules les adresses professionnelles validées sont affichées conformément à la charte de confidentialité CAMERMODE.",
                  style: TextStyle(fontSize: 11, color: AppColors.texteSecondaire),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bouton Itinéraire
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Calcul de l'itinéraire vers ${article.prestataireAdresse}..."),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              icon: const Icon(Icons.directions, color: Colors.white),
              label: const Text("OUVRIR L'ITINÉRAIRE", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.noir,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
