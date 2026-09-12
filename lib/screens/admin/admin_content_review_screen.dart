
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/article_model.dart';
import '../../services/article_service.dart';

class AdminContentReviewScreen extends StatelessWidget {
  const AdminContentReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Surveillance du Contenu Global"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<ArticleModel>>(
        stream: ArticleService().getAllArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.rose));
          }
          final articles = snapshot.data ?? [];
          
          if (articles.isEmpty) return const Center(child: Text("Aucune photo publiée sur la plateforme."));

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
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
                          Text(art.titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text("Par : ${art.prestataireNom}", style: const TextStyle(fontSize: 9, color: AppColors.texteSecondaire)),
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
