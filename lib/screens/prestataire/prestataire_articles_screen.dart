
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/article_service.dart';
import '../../services/auth_service.dart';
import '../../models/article_model.dart';
import 'add_article_screen.dart';

class PrestataireArticlesScreen extends StatelessWidget {
  const PrestataireArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articleService = ArticleService();
    final authService = AuthService();

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Mes Créations", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddArticleScreen())),
            icon: const Icon(Icons.add_circle, color: AppColors.rose, size: 28),
          ),
        ],
      ),
      body: StreamBuilder<List<ArticleModel>>(
        stream: articleService.getPrestataireArticles(authService.currentUser?.uid ?? ""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.rose));
          }

          final articles = snapshot.data ?? [];

          if (articles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("Vous n'avez pas encore de créations.", style: TextStyle(color: AppColors.texteSecondaire)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddArticleScreen())),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose),
                    child: const Text("AJOUTER MA PREMIÈRE CRÉATION", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final art = articles[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Image.network(art.imageUrl, fit: BoxFit.cover, width: double.infinity),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(art.titre, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text("${art.prix.toInt()} FCFA", style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
