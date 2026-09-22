import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/article_model.dart';
import '../../services/article_service.dart';
import '../../services/auth_service.dart';
import '../article_detail_screen.dart';
import 'add_article_screen.dart';

class PrestataireArticlesScreen extends StatefulWidget {
  const PrestataireArticlesScreen({super.key});

  @override
  State<PrestataireArticlesScreen> createState() => _PrestataireArticlesScreenState();
}

class _PrestataireArticlesScreenState extends State<PrestataireArticlesScreen> {
  final ArticleService _articleService = ArticleService();
  final AuthService _authService = AuthService();
  String _filterType = "Tous"; // "Tous", "Publiés", "Brouillons"
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final uid = _authService.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text(
          "Mes Créations",
          style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.noir),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddArticleScreen()),
            ),
            icon: const Icon(Icons.add_circle, color: AppColors.rose, size: 28),
            tooltip: "Ajouter un article",
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              children: [
                // Champ de recherche
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Rechercher une création...",
                    prefixIcon: const Icon(Icons.search, color: AppColors.rose, size: 20),
                    filled: true,
                    fillColor: AppColors.roseClair.withOpacity(0.5),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Chips de filtre
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("Tous"),
                      const SizedBox(width: 8),
                      _buildFilterChip("Publiés"),
                      const SizedBox(width: 8),
                      _buildFilterChip("Brouillons"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste des articles
          Expanded(
            child: StreamBuilder<List<ArticleModel>>(
              stream: _articleService.getPrestataireArticles(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.rose));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Erreur de chargement : ${snapshot.error}"),
                  );
                }

                var articles = snapshot.data ?? [];

                // Filtrage
                if (_filterType == "Publiés") {
                  articles = articles.where((a) => a.isPublished).toList();
                } else if (_filterType == "Brouillons") {
                  articles = articles.where((a) => !a.isPublished).toList();
                }

                if (_searchQuery.isNotEmpty) {
                  articles = articles.where((a) {
                    return a.titre.toLowerCase().contains(_searchQuery) ||
                        a.categorie.toLowerCase().contains(_searchQuery) ||
                        a.tags.any((t) => t.toLowerCase().contains(_searchQuery));
                  }).toList();
                }

                if (articles.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                              ],
                            ),
                            child: const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.rose),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Aucun article trouvé",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.noir),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Ajoutez vos confections, tresses ou modèles de couture pour que les clients puissent les découvrir et réserver.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.texteSecondaire, fontSize: 13),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddArticleScreen()),
                            ),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text("AJOUTER UNE CRÉATION", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.rose,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final art = articles[index];
                    return _buildArticleCard(context, art);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterType == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.rose,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.noir,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: Colors.grey[100],
      onSelected: (val) {
        if (val) setState(() => _filterType = label);
      },
    );
  }

  Widget _buildArticleCard(BuildContext context, ArticleModel art) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: art)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Container(
                    width: 110,
                    height: 120,
                    color: Colors.grey[100],
                    child: art.imageUrl.isNotEmpty
                      ? Image.network(
                          art.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint("❌ [UI] Erreur Image.network : ${art.imageUrl}");
                            return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
                          },
                        )
                      : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 14),
                // Informations
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge Statut (Publié / Brouillon)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: art.isPublished
                                    ? Colors.green.withOpacity(0.12)
                                    : Colors.orange.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    art.isPublished ? Icons.check_circle : Icons.visibility_off,
                                    size: 12,
                                    color: art.isPublished ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    art.isPublished ? "Publié" : "Brouillon",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: art.isPublished ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              art.type == ArticleType.couture ? "Couture" : "Coiffure",
                              style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          art.titre,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.noir),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          art.categorie,
                          style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${art.prix.toInt()} FCFA",
                          style: const TextStyle(
                            color: AppColors.rose,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const Divider(height: 1),
          // Actions rapides sur l'article (Modifier, Publier/Dépublier, Supprimer)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton Publier / Dépublier
                TextButton.icon(
                  onPressed: () async {
                    final success = await _articleService.togglePublishStatus(art.id, art.isPublished);
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(art.isPublished ? "Article retiré du catalogue (Brouillon)" : "Article publié avec succès !"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    art.isPublished ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 16,
                    color: art.isPublished ? Colors.orange : Colors.green,
                  ),
                  label: Text(
                    art.isPublished ? "Dépublier" : "Publier",
                    style: TextStyle(
                      color: art.isPublished ? Colors.orange : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Bouton Modifier
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddArticleScreen(existingArticle: art)),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.blue),
                  label: const Text("Modifier", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                ),

                // Bouton Supprimer
                IconButton(
                  onPressed: () => _confirmDeleteArticle(context, art),
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  tooltip: "Supprimer",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteArticle(BuildContext context, ArticleModel art) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Supprimer cette création ?"),
        content: Text("Êtes-vous sûr de vouloir supprimer définitivement \"${art.titre}\" ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await _articleService.deleteArticle(art.id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Article supprimé avec succès"), backgroundColor: Colors.red),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erreur lors de la suppression")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
