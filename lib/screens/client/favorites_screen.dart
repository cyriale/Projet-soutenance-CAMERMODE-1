
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/article_model.dart';
import '../../services/dashboard_service.dart';
import '../article_detail_screen.dart';
import 'prestataire_detail_screen.dart';
import 'saved_images_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const FavoritesScreen({super.key, this.onBack});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DashboardService _service = DashboardService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        final favArticles = _service.articles.where((a) => a.isFavorite && a.type == ArticleType.couture).toList();
        final favHairstyles = _service.articles.where((a) => a.isFavorite && a.type == ArticleType.coiffure).toList();

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
              "Mes Favoris",
              style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedImagesScreen()));
                },
                icon: const Icon(Icons.collections_bookmark_outlined, color: AppColors.rose, size: 18),
                label: const Text("Mes Sauvegardes", style: TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.rose,
              unselectedLabelColor: AppColors.texteSecondaire,
              indicatorColor: AppColors.rose,
              indicatorWeight: 3,
              tabs: [
                Tab(text: "Vêtements (${favArticles.length})"),
                Tab(text: "Coiffures (${favHairstyles.length})"),
                Tab(text: "Prestataires (${_service.favoritePrestataireIds.length})"),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // 1. Articles Couture favoris
              _buildArticleGrid(favArticles, "Aucun vêtement en favori"),

              // 2. Coiffures favorites
              _buildArticleGrid(favHairstyles, "Aucune coiffure en favori"),

              // 3. Prestataires favoris
              _buildPrestatairesList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArticleGrid(List<ArticleModel> list, String emptyMessage) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(emptyMessage, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.noir)),
            const SizedBox(height: 4),
            const Text("Cliquez sur 🔖 ou ❤️ pour ajouter des créations.", style: TextStyle(color: AppColors.texteSecondaire, fontSize: 12)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.7,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final art = list[index];
        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: art)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(art.imageUrl, fit: BoxFit.cover, width: double.infinity),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(art.titre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(art.prestataireNom, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text("${art.prix.toInt()} FCFA", style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.w900, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.bookmark, size: 18, color: AppColors.rose),
                      onPressed: () => _service.toggleFavorite(art.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrestatairesList() {
    final favIds = _service.favoritePrestataireIds;
    final favProvidersArticles = _service.articles.where((a) => favIds.contains(a.prestataireId)).toList();

    if (favIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text("Aucun prestataire favori", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.noir)),
            const SizedBox(height: 4),
            const Text("Suivez vos salons et créateurs favoris pour voir leurs nouveautés.", style: TextStyle(color: AppColors.texteSecondaire, fontSize: 12)),
          ],
        ),
      );
    }

    // Dédupliquer par prestataire
    final Map<String, ArticleModel> uniqueProviders = {};
    for (var art in favProvidersArticles) {
      uniqueProviders[art.prestataireId] = art;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: uniqueProviders.values.map((art) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.ligne),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(art.prestatairePhoto),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(art.prestataireNom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                if (art.prestataireVerified) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, color: Colors.blue, size: 16),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text("${art.prestataireRating} (${art.prestataireAvisCount} avis)", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    Text(art.prestataireDistance, style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(art.prestataireAdresse, style: const TextStyle(fontSize: 11, color: AppColors.texteSecondaire)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.rose),
              onPressed: () => _service.toggleFavoritePrestataire(art.prestataireId),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrestataireDetailScreen(
                    prestataireId: art.prestataireId,
                    nom: art.prestataireNom,
                    photoUrl: art.prestatairePhoto,
                    rating: art.prestataireRating,
                    avisCount: art.prestataireAvisCount,
                    isVerified: art.prestataireVerified,
                    adresse: art.prestataireAdresse,
                    distance: art.prestataireDistance,
                    offersHomeService: art.prestationADomicile,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
