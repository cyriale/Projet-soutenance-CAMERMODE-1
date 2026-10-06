
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/article_model.dart';
import '../../models/user_model.dart';
import '../../services/article_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/ai_recommendation_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../compronents/app_cached_image.dart';
import '../article_detail_screen.dart';
import 'prestataire_detail_screen.dart';
import 'share_sheet.dart';
import 'virtual_try_on_screen.dart';
import 'body_scan_screen.dart';
import 'face_scan_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onExitGuestMode;
  const HomeScreen({super.key, this.onExitGuestMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardService _dashboardService = DashboardService();
  final ArticleService _articleService = ArticleService();
  final AIRecommendationService _recommendationService = AIRecommendationService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  String _selectedCategory = "Tous";
  String _activeTab = "Pour vous";
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    "Tous",
    "Robes de Soirée",
    "Tresses & Nattes",
    "Tailleur & Chic",
    "Boubous & Cérémonie",
    "Cheveux Naturels",
    "Tradition & Héritage",
    "Locks & Twists",
  ];

  final List<String> _tabs = [
    "Pour vous",
    "Tendances 🔥",
    "Nouveautés ✨",
    "Vêtements 👗",
    "Coiffures 💇",
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authUser = _authService.currentUser;
    if (authUser != null) {
      final u = await _userService.getUser(authUser.uid);
      if (mounted) setState(() => _currentUser = u);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ArticleModel>>(
      stream: _articleService.getAllArticles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.rose)));
        }

        final firestoreArticles = snapshot.data ?? [];
        final allArticles = firestoreArticles.isNotEmpty ? firestoreArticles : DashboardService().articles;

        List<ArticleModel> filtered = _activeTab == "Pour vous" 
            ? _recommendationService.getPersonalizedFeed(allArticles, _currentUser)
            : allArticles;

        // Filtrage Catégorie
        if (_selectedCategory != "Tous") {
          filtered = filtered.where((a) => a.categorie == _selectedCategory).toList();
        }

        // Filtrage Onglet
        if (_activeTab == "Vêtements 👗") {
          filtered = filtered.where((a) => a.type == ArticleType.couture).toList();
        } else if (_activeTab == "Coiffures 💇") {
          filtered = filtered.where((a) => a.type == ArticleType.coiffure).toList();
        } else if (_activeTab == "Tendances 🔥") {
          filtered = List.from(filtered)..sort((a, b) => b.likesCount.compareTo(a.likesCount));
        }

        // Recherche texte
        final query = _searchController.text.trim().toLowerCase();
        if (query.isNotEmpty) {
          filtered = filtered.where((a) =>
              a.titre.toLowerCase().contains(query) ||
              a.prestataireNom.toLowerCase().contains(query) ||
              a.categorie.toLowerCase().contains(query)).toList();
        }

        return Scaffold(
          backgroundColor: AppColors.roseClair,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // En-tête CAMERMODE & Recherche
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (Navigator.canPop(context)) ...[
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back, color: AppColors.noir),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "C",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "CAMERMODE",
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: AppColors.noir,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.noir, size: 26),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Vous n'avez pas de nouvelle notification.")),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Barre de Recherche Visuelle
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: "Rechercher une robe, tresses, coiffeur, créateur...",
                              hintStyle: const TextStyle(color: AppColors.texteSecondaire, fontSize: 13),
                              prefixIcon: const Icon(Icons.search, color: AppColors.rose),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: AppColors.texteSecondaire, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bannière Recommandation Morphologique & Faciale Personnalisée (IA)
                // On l'affiche uniquement si c'est un client (selon la demande utilisateur)
                if (_currentUser?.role == UserRole.client)
                  SliverToBoxAdapter(
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.auto_awesome, color: AppColors.rose, size: 24),
                                    SizedBox(width: 10),
                                    Text("Intelligence Artificielle CamerMode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text("Scannez votre silhouette ou votre visage pour obtenir des recommandations 100% personnalisées.", style: TextStyle(color: AppColors.texteSecondaire, fontSize: 13)),
                                const SizedBox(height: 20),
                                Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: AppColors.rose.withOpacity(0.1), shape: BoxShape.circle),
                                      child: const Icon(Icons.accessibility_new, color: AppColors.rose),
                                    ),
                                    title: const Text("Scan Morphologique Corporel 3D", style: TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(_currentUser?.morphologieType != null ? "Actuel : ${_currentUser!.morphologieType}" : "Mesurez votre silhouette pour la couture"),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BodyScanScreen())).then((_) => _loadUser());
                                    },
                                  ),
                                ),
                                const Divider(),
                                Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                                      child: const Icon(Icons.face_retouching_natural, color: Colors.purple),
                                    ),
                                    title: const Text("Scan Visage & Morphologie Coiffure", style: TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(_currentUser?.formeVisage != null ? "Actuel : ${_currentUser!.formeVisage}" : "Détectez votre forme de visage pour vos coiffures"),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FaceScanScreen())).then((_) => _loadUser());
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2C2523), Color(0xFF1C1C1C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.rose.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.auto_awesome, color: AppColors.rose, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Recommandations IA adaptées",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _currentUser?.morphologieType != null
                                        ? "Morphologie : ${_currentUser!.morphologieType!}"
                                        : "Cliquez ici pour scanner votre silhouette / visage",
                                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.rose,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "SCANNER IA",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Filtres par Onglets (Pour vous, Tendances, Nouveautés...)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _tabs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final tab = _tabs[index];
                        final isSelected = _activeTab == tab;
                        return ChoiceChip(
                          label: Text(tab),
                          selected: isSelected,
                          selectedColor: AppColors.noir,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.noir,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                          side: BorderSide(color: isSelected ? AppColors.noir : AppColors.ligne),
                          onSelected: (sel) {
                            if (sel) setState(() => _activeTab = tab);
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),

                // Filtres par Catégorie (Chips)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;
                        return ActionChip(
                          label: Text(cat),
                          backgroundColor: isSelected ? AppColors.rose.withOpacity(0.15) : Colors.transparent,
                          side: BorderSide(color: isSelected ? AppColors.rose : AppColors.ligne),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.rose : AppColors.texteSecondaire,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onPressed: () => setState(() => _selectedCategory = cat),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Fil Pinterest / Instagram : Grille visuelle de publications
                filtered.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Text(
                              "Aucun article ne correspond à votre recherche.",
                              style: TextStyle(color: AppColors.texteSecondaire),
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.58, // Format vertical Pinterest
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final article = filtered[index];
                              return _buildPublicationCard(context, article);
                            },
                            childCount: filtered.length,
                          ),
                        ),
                      ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          ),
        );
      },
    );
  }

  // Publication Card (Pinterest / Instagram Inspired)
  Widget _buildPublicationCard(BuildContext context, ArticleModel article) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo Principale + Actions Flottantes (❤️ Like, 🔖 Favori, 💾 Enregistrer)
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    // Si c'est un visiteur (_currentUser est null), on redirige vers le login
                    if (_currentUser == null) {
                      _showGuestRestrictionDialog(context);
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: AppCachedImage(
                      imageUrl: article.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),

                // Dégradé supérieur pour les icônes
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                      ),
                    ),
                  ),
                ),

                // Bouton J'aime ❤️ (Section 3)
                Positioned(
                  top: 8,
                  left: 8,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white.withOpacity(0.85),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        article.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: article.isLiked ? AppColors.rose : AppColors.noir,
                        size: 18,
                      ),
                      onPressed: () => _dashboardService.toggleLike(article.id),
                    ),
                  ),
                ),

                // Boutons Favori 🔖 et Enregistrer 💾 (Section 4 & 5)
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
                          icon: Icon(
                            article.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                            color: article.isFavorite ? AppColors.rose : AppColors.noir,
                            size: 18,
                          ),
                          onPressed: () => _dashboardService.toggleFavorite(article.id),
                        ),
                      ),
                      const SizedBox(width: 4),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withOpacity(0.85),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            article.isSaved ? Icons.save : Icons.save_outlined,
                            color: article.isSaved ? AppColors.rose : AppColors.noir,
                            size: 16,
                          ),
                          tooltip: "Enregistrer l'image",
                          onPressed: () => _dashboardService.toggleSaveImage(article.id),
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge Essayage Virtuel Rapide
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {
                      if (_currentUser == null) {
                        _redirectToLogin(context);
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VirtualTryOnScreen(article: article)),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.rose, width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: AppColors.rose, size: 12),
                          SizedBox(width: 4),
                          Text("Essayer", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Informations & Profil du Prestataire (Section 1)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                InkWell(
                  onTap: () {
                    if (_currentUser == null) {
                      _redirectToLogin(context);
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
                    );
                  },
                  child: Text(
                    article.titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.noir),
                  ),
                ),
                const SizedBox(height: 2),

                // Prix
                Text(
                  "${article.prix.toInt()} FCFA",
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.rose, fontSize: 13),
                ),
                const SizedBox(height: 6),

                // Profil Prestataire cliquable avec Badge Vérifié (Section 1 & 7)
                InkWell(
                  onTap: () {
                    // Restriction visiteur également ici
                    if (_currentUser == null) {
                      _showGuestRestrictionDialog(context);
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrestataireDetailScreen(
                          prestataireId: article.prestataireId,
                          nom: article.prestataireNom,
                          photoUrl: article.prestatairePhoto,
                          rating: article.prestataireRating,
                          avisCount: article.prestataireAvisCount,
                          isVerified: article.prestataireVerified,
                          adresse: article.prestataireAdresse,
                          distance: article.prestataireDistance,
                          offersHomeService: article.prestationADomicile,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(article.prestatairePhoto),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                article.prestataireNom,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.noir),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (article.prestataireVerified) ...[
                              const SizedBox(width: 2),
                              const Icon(Icons.verified, color: Colors.blue, size: 12),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.share, size: 14, color: AppColors.texteSecondaire),
                        onPressed: () => ShareSheet.show(context, title: article.titre, description: article.description),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGuestRestrictionDialog(BuildContext context) {
    _redirectToLogin(context);
  }

  void _redirectToLogin(BuildContext context) {
    if (widget.onExitGuestMode != null) {
      widget.onExitGuestMode!();
    }
  }
}
