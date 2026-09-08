
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/dashboard_service.dart';
import '../article_detail_screen.dart';
import 'share_sheet.dart';

class SavedImagesScreen extends StatelessWidget {
  const SavedImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DashboardService();

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final savedArticles = service.articles.where((a) => service.savedArticleIds.contains(a.id)).toList();

        return Scaffold(
          backgroundColor: AppColors.roseClair,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "Mes Sauvegardes",
              style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.noir),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: savedArticles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 70, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        "Aucune image sauvegardée",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.noir),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Enregistrez des images depuis le fil d'actualité pour créer votre moodboard d'inspiration.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.texteSecondaire, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: savedArticles.length,
                  itemBuilder: (context, index) {
                    final art = savedArticles[index];
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
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
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
                                      Text(
                                        art.titre,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        art.prestataireNom,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Actions flottantes : Partager & Supprimer de la sauvegarde
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.white.withOpacity(0.85),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.share, size: 16, color: AppColors.noir),
                                      onPressed: () => ShareSheet.show(context, title: art.titre, description: art.description),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.white.withOpacity(0.85),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.bookmark_remove, size: 16, color: AppColors.rose),
                                      onPressed: () => service.toggleSaveImage(art.id),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
