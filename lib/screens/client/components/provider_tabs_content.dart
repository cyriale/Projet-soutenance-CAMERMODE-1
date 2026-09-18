import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../models/article_model.dart';
import '../../../models/user_model.dart';
import '../article_detail_screen.dart';
import '../booking_dialog.dart';

/// Contient le contenu des différents onglets du profil prestataire
class ProviderTabsContent extends StatelessWidget {
  final TabController tabController;
  final List<ArticleModel> providerArticles;
  final List<dynamic> reviews;

  const ProviderTabsContent({
    super.key,
    required this.tabController,
    required this.providerArticles,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        _buildCreationsTab(context),
        _buildServicesTab(context),
        _buildGalleryTab(context),
        _buildReviewsTab(context),
      ],
    );
  }

  // --- ONGLET 1 : CRÉATIONS ---
  Widget _buildCreationsTab(BuildContext context) {
    if (providerArticles.isEmpty) return const Center(child: Text("Aucune création publiée"));
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: providerArticles.length,
      itemBuilder: (context, index) {
        final art = providerArticles[index];
        return _buildArticleGridItem(context, art);
      },
    );
  }

  // --- ONGLET 2 : SERVICES ---
  Widget _buildServicesTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildServiceCard(context, "Confection sur-mesure", "Prise de mesures, coupe, essayage intermédiaire et finitions", "À partir de 35 000 FCFA", Icons.straighten),
        _buildServiceCard(context, "Retouche & Ajustement", "Ajustements d'ourlets, cintrage et reprises de robes/vestes", "À partir de 10 000 FCFA", Icons.cut),
        _buildServiceCard(context, "Stylisme & Conseil Mode", "Accompagnement personnalisé pour choix de tissus et modèles", "20 000 FCFA / séance", Icons.auto_awesome),
      ],
    );
  }

  // --- ONGLET 3 : GALERIE ---
  Widget _buildGalleryTab(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: providerArticles.length * 2,
      itemBuilder: (context, index) {
        final art = providerArticles[index % providerArticles.length];
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(art.imageUrl, fit: BoxFit.cover),
        );
      },
    );
  }

  // --- ONGLET 4 : AVIS ---
  Widget _buildReviewsTab(BuildContext context) {
    if (reviews.isEmpty) return const Center(child: Text("Aucun avis client pour le moment."));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final r = reviews[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.ligne)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 16, backgroundColor: AppColors.roseClair, child: Icon(Icons.person, color: AppColors.noir, size: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.userNom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(r.serviceTitre, style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 11)),
                        ],
                      ),
                    ),
                    Row(children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.amber, size: 14))),
                  ],
                ),
                const SizedBox(height: 10),
                Text(r.commentaire, style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS DE CARTES ---
  Widget _buildArticleGridItem(BuildContext context, ArticleModel art) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: art))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.network(art.imageUrl, fit: BoxFit.cover, width: double.infinity))),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(art.titre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text("${art.prix.toInt()} FCFA", style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.w900, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String titre, String desc, String tarif, IconData icon) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.ligne)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(backgroundColor: AppColors.rose.withOpacity(0.12), child: Icon(icon, color: AppColors.rose)),
        title: Text(titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire)),
            const SizedBox(height: 6),
            Text(tarif, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.rose, fontSize: 13)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            if (providerArticles.isNotEmpty) BookingDialog.show(context, providerArticles.first);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.noir, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text("Réserver", style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
