
import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../core/app_colors.dart';
import '../compronents/app_button.dart';
import 'complete_profile_screen.dart';

class ArticleDetailScreen extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailScreen({super.key, required this.article});

  // Simulation : Est-ce que les mensurations sont remplies ?
  // Dans le vrai backend, on vérifiera user.tourPoitrine != null etc.
  final bool _areMensurationsFilled = false; 

  void _onTryOnPressed(BuildContext context) async {
    if (_areMensurationsFilled) {
      // 1. Si déjà rempli, on lance directement l'essai (on simule un message pour l'instant)
      _showTryOnSuccess(context);
    } else {
      // 2. Si non rempli, on redirige vers le formulaire de mensurations
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteProfileScreen(type: article.type),
        ),
      );

      // 3. Après l'enregistrement, on lance l'essai si l'utilisateur a validé
      if (result == true && context.mounted) {
        _showTryOnSuccess(context);
      }
    }
  }

  void _showTryOnSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Lancement de l'essayage virtuel 3D..."),
        backgroundColor: AppColors.rose,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isCouture = article.type == ArticleType.couture;

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                article.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.roseClair,
                  child: const Icon(Icons.image, size: 100, color: Colors.white),
                ),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: const Color(0xB3FFFFFF),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.noir),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          article.titre,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.noir),
                        ),
                      ),
                      Text(
                        "${article.prix} FCFA",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.rose),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      const Text("4.8 (120 avis)", style: TextStyle(color: AppColors.texteSecondaire)),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCouture ? Colors.blue[50] : Colors.purple[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isCouture ? "COUTURE" : "COIFFURE",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCouture ? Colors.blue : Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.noir)),
                  const SizedBox(height: 8),
                  Text(article.description, style: const TextStyle(color: AppColors.noir, height: 1.5)),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: AppButton(
          text: isCouture ? "ESSAYER SUR MON CORPS (3D)" : "VOIR SUR MON VISAGE (AR)",
          onPressed: () => _onTryOnPressed(context),
        ),
      ),
    );
  }
}
