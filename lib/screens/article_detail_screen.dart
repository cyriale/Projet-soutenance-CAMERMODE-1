
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/article_model.dart';
import '../services/dashboard_service.dart';
import 'client/booking_dialog.dart';
import 'client/chat_conversation_screen.dart';
import 'client/prestataire_detail_screen.dart';
import 'client/provider_location_dialog.dart';
import 'client/share_sheet.dart';
import 'client/virtual_try_on_screen.dart';

class ArticleDetailScreen extends StatefulWidget {
  final ArticleModel article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final DashboardService _service = DashboardService();
  late String _selectedColor;
  late String _selectedSize;

  final Map<String, Color> _colorPalette = {
    "Noir": Colors.black,
    "Blanc": Colors.white,
    "Rouge": const Color(0xFFD32F2F),
    "Bleu": const Color(0xFF1976D2),
    "Vert": const Color(0xFF388E3C),
    "Jaune": const Color(0xFFFBC02D),
    "Or": const Color(0xFFFFD700),
    "Bordeaux": const Color(0xFF880E4F),
  };

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.article.couleursDisponibles.isNotEmpty
        ? widget.article.couleursDisponibles.first
        : "Noir";
    _selectedSize = widget.article.taillesDisponibles.isNotEmpty
        ? widget.article.taillesDisponibles.first
        : "M";
  }

  @override
  Widget build(BuildContext context) {
    final bool isCouture = widget.article.type == ArticleType.couture;

    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        // Obtenir la version la plus à jour de l'article depuis le service
        final currentArticle = _service.articles.firstWhere(
          (a) => a.id == widget.article.id,
          orElse: () => widget.article,
        );

        return Scaffold(
          backgroundColor: AppColors.roseClair,
          body: CustomScrollView(
            slivers: [
              // Image Header immersif avec actions flottantes
              SliverAppBar(
                expandedHeight: 440,
                pinned: true,
                backgroundColor: AppColors.noir,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.noir, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: Icon(
                        currentArticle.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: currentArticle.isLiked ? AppColors.rose : AppColors.noir,
                        size: 20,
                      ),
                      onPressed: () => _service.toggleLike(currentArticle.id),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: Icon(
                        currentArticle.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: currentArticle.isFavorite ? AppColors.rose : AppColors.noir,
                        size: 20,
                      ),
                      onPressed: () => _service.toggleFavorite(currentArticle.id),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: Icon(
                        currentArticle.isSaved ? Icons.save : Icons.save_outlined,
                        color: currentArticle.isSaved ? AppColors.rose : AppColors.noir,
                        size: 20,
                      ),
                      tooltip: "Enregistrer dans Mes Sauvegardes",
                      onPressed: () => _service.toggleSaveImage(currentArticle.id),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: AppColors.noir, size: 20),
                      onPressed: () => ShareSheet.show(
                        context,
                        title: currentArticle.titre,
                        description: currentArticle.description,
                        imageUrl: currentArticle.imageUrl,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        currentArticle.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.roseClair,
                          child: const Icon(Icons.image, size: 100, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu détaillé de l'article
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Catégorie, Like Counter & Type
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCouture ? Colors.blue.withOpacity(0.12) : Colors.purple.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              currentArticle.categorie.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isCouture ? Colors.blue[800] : Colors.purple[800],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: AppColors.rose, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "${currentArticle.likesCount} personnes aiment cette création",
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.texteSecondaire),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Titre & Prix
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              currentArticle.titre,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.noir),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${currentArticle.prix.toInt()} FCFA",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.rose),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Carte Prestataire
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrestataireDetailScreen(
                                prestataireId: currentArticle.prestataireId,
                                nom: currentArticle.prestataireNom,
                                photoUrl: currentArticle.prestatairePhoto,
                                rating: currentArticle.prestataireRating,
                                avisCount: currentArticle.prestataireAvisCount,
                                isVerified: currentArticle.prestataireVerified,
                                adresse: currentArticle.prestataireAdresse,
                                distance: currentArticle.prestataireDistance,
                                offersHomeService: currentArticle.prestationADomicile,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.ligne),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(currentArticle.prestatairePhoto),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            currentArticle.prestataireNom,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (currentArticle.prestataireVerified) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified, color: Colors.blue, size: 16),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${currentArticle.prestataireRating} (${currentArticle.prestataireAvisCount} avis)",
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "• ${currentArticle.prestataireDistance}",
                                          style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Text("Voir profil", style: TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold, fontSize: 12)),
                              const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.rose),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sélection des Couleurs disponibles (Section 2 & 9)
                      const Text(
                        "Couleurs disponibles",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.noir),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: currentArticle.couleursDisponibles.map((colorName) {
                            final isSelected = _selectedColor == colorName;
                            Color chipColor = Colors.grey;
                            for (var entry in _colorPalette.entries) {
                              if (colorName.toLowerCase().contains(entry.key.toLowerCase())) {
                                chipColor = entry.value;
                                break;
                              }
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                avatar: CircleAvatar(backgroundColor: chipColor, radius: 8),
                                label: Text(colorName),
                                selected: isSelected,
                                selectedColor: AppColors.rose.withOpacity(0.15),
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.rose : AppColors.noir,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                side: BorderSide(color: isSelected ? AppColors.rose : AppColors.ligne),
                                onSelected: (val) {
                                  if (val) setState(() => _selectedColor = colorName);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sélection des Tailles disponibles
                      Text(
                        isCouture ? "Tailles disponibles & Sur-mesure" : "Longueurs & Volumes",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.noir),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: currentArticle.taillesDisponibles.map((size) {
                          final isSelected = _selectedSize == size;
                          return ChoiceChip(
                            label: Text(size),
                            selected: isSelected,
                            selectedColor: AppColors.rose,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.noir,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedSize = size);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        "Description & Confection",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.noir),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentArticle.description,
                        style: const TextStyle(color: AppColors.noir, height: 1.5, fontSize: 14),
                      ),
                      const SizedBox(height: 20),

                      // Bouton Localisation du prestataire
                      OutlinedButton.icon(
                        onPressed: () => ProviderLocationDialog.show(context, currentArticle),
                        icon: const Icon(Icons.location_on_outlined, color: AppColors.noir),
                        label: Text(
                          "Voir la localisation de l'atelier (${currentArticle.prestataireAdresse})",
                          style: const TextStyle(color: AppColors.noir, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          side: const BorderSide(color: AppColors.ligne),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 120), // Espace pour le bas d'écran
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Barre d'action flottante inférieure
          bottomSheet: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Contacter
                  IconButton.filledTonal(
                    onPressed: () {
                      final convId = _service.getOrCreateConversation(
                        prestataireId: currentArticle.prestataireId,
                        prestataireNom: currentArticle.prestataireNom,
                        prestatairePhoto: currentArticle.prestatairePhoto,
                        articleRefTitre: currentArticle.titre,
                        articleRefImageUrl: currentArticle.imageUrl,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatConversationScreen(
                            conversationId: convId,
                            prestataireNom: currentArticle.prestataireNom,
                            prestatairePhoto: currentArticle.prestatairePhoto,
                            prestataireVerified: currentArticle.prestataireVerified,
                            articleRefTitre: currentArticle.titre,
                            articleRefImageUrl: currentArticle.imageUrl,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, color: AppColors.noir),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Essayer virtuellement (Studio 2D/AR)
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VirtualTryOnScreen(article: currentArticle),
                          ),
                        );
                      },
                      icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                      label: Text(
                        isCouture ? "ESSAYER SUR MOI" : "VOIR SUR MON VISAGE",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rose,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Réserver
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => BookingDialog.show(context, currentArticle),
                      icon: const Icon(Icons.calendar_month, color: Colors.white, size: 18),
                      label: const Text(
                        "RÉSERVER",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.noir,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
