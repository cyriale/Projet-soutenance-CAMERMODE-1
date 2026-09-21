import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/article_model.dart';
import '../../services/dashboard_service.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../services/client_ai_service.dart'; // Utilisation du nouveau backend client
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../article_detail_screen.dart';
import 'booking_dialog.dart';
import 'chat_conversation_screen.dart';

/// ===========================================================================
/// ÉCRAN DÉTAIL PRESTATAIRE (VUE CLIENT)
/// Gère la vitrine d'un professionnel avec recommandations intelligentes.
/// ===========================================================================
class PrestataireDetailScreen extends StatefulWidget {
  final String prestataireId;
  final String nom;
  final String photoUrl;
  final double rating;
  final int avisCount;
  final bool isVerified;
  final String adresse;
  final String distance;
  final bool offersHomeService;

  const PrestataireDetailScreen({
    super.key,
    required this.prestataireId,
    required this.nom,
    required this.photoUrl,
    required this.rating,
    required this.avisCount,
    this.isVerified = true,
    required this.adresse,
    required this.distance,
    this.offersHomeService = true,
  });

  @override
  State<PrestataireDetailScreen> createState() => _PrestataireDetailScreenState();
}

class _PrestataireDetailScreenState extends State<PrestataireDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DashboardService _service = DashboardService();
  final ClientAIService _clientBackend = ClientAIService(); // Nouveau Backend Client
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();
  
  UserModel? _currentUser; // Stocke le profil du client connecté

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUser(); // Charge les données du client pour l'IA
  }

  /// Charge le profil du client pour savoir quelle morphologie utiliser pour l'IA
  Future<void> _loadUser() async {
    final u = _auth.currentUser;
    if (u != null) {
      final profile = await _userService.getUser(u.uid);
      if (mounted) setState(() => _currentUser = profile);
    }
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
        final providerArticles = _service.articles.where((a) => a.prestataireId == widget.prestataireId).toList();
        final isFav = _service.favoritePrestataireIds.contains(widget.prestataireId);
        final reviews = _service.reviews.where((r) => r.prestataireId == widget.prestataireId).toList();

        return Scaffold(
          backgroundColor: AppColors.roseClair,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // --- 1. IMAGE DE COUVERTURE ---
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: AppColors.noir,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: AppColors.rose),
                      onPressed: () => _service.toggleFavoritePrestataire(widget.prestataireId),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.network(widget.photoUrl, fit: BoxFit.cover),
                  ),
                ),

                // --- 2. INFOS PRESTATAIRE (Header + Boutons) ---
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 20),
                        _buildActionButtons(providerArticles),
                      ],
                    ),
                  ),
                ),

                // --- 3. BARRE D'ONGLETS ---
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.rose,
                      unselectedLabelColor: AppColors.texteSecondaire,
                      indicatorColor: AppColors.rose,
                      tabs: const [
                        Tab(text: "Créations"),
                        Tab(text: "Services"),
                        Tab(text: "Galerie"),
                        Tab(text: "Avis"),
                      ],
                    ),
                  ),
                ),
              ];
            },
            // --- 4. CONTENU DES ONGLETS ---
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildCreationsTab(providerArticles),
                _buildServicesTab(),
                _buildGalleryTab(providerArticles),
                _buildReviewsTab(reviews),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET : EN-TÊTE DU PROFIL ---
  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(radius: 35, backgroundImage: NetworkImage(widget.photoUrl)),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.nom, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (widget.isVerified) const Icon(Icons.verified, color: Colors.blue, size: 18),
                ],
              ),
              Text("${widget.rating} ⭐ (${widget.avisCount} avis)"),
              Text("📍 ${widget.adresse} • ${widget.distance}", style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire)),
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET : BOUTONS D'ACTION ---
  Widget _buildActionButtons(List<ArticleModel> articles) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _startChat(),
            child: const Text("Contacter", style: TextStyle(color: AppColors.noir)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => articles.isNotEmpty ? BookingDialog.show(context, articles.first) : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose),
            child: const Text("Réserver", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // --- ONGLET 1 : CRÉATIONS (Avec Recommandation IA en haut) ---
  Widget _buildCreationsTab(List<ArticleModel> articles) {
    if (articles.isEmpty) return const Center(child: Text("Aucune création publiée"));

    return ListView(
      children: [
        // --- SECTION IA : RECOMMANDATIONS PERSONNALISÉES ---
        if (_currentUser != null && (_currentUser!.morphologieType != null || _currentUser!.formeVisage != null))
          _buildAIRecommendationSection(articles),

        // Grille de tous les articles
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text("TOUTES LES CRÉATIONS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.texteSecondaire)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.7),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final art = articles[index];
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: art))),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.network(art.imageUrl, fit: BoxFit.cover, width: double.infinity))),
                    Padding(padding: const EdgeInsets.all(8.0), child: Text(art.titre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))),
                    Text("${art.prix.toInt()} FCFA", style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- WIDGET : LA BANNIÈRE DE RECOMMANDATION IA ---
  Widget _buildAIRecommendationSection(List<ArticleModel> articles) {
    final topThree = _clientBackend.getPersonalizedRecommendations(articles, _currentUser!);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.noir, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.rose, size: 20),
              SizedBox(width: 8),
              Text("RECOMMANDÉ PAR L'IA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),
          // Appel au backend IA client pour le conseil du styliste
          FutureBuilder<String>(
            future: _clientBackend.getStylistNote(_currentUser!, topThree),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? "Analyse de votre style en cours...",
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic),
              );
            },
          ),
          const SizedBox(height: 15),
          // Liste horizontale des 3 meilleurs articles
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: topThree.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: topThree[i]))),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), image: DecorationImage(image: NetworkImage(topThree[i].imageUrl), fit: BoxFit.cover)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ONGLET : SERVICES ---
  Widget _buildServicesTab() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: const [
        ListTile(leading: Icon(Icons.cut, color: AppColors.rose), title: Text("Confection sur-mesure"), subtitle: Text("À partir de 35 000 FCFA")),
        ListTile(leading: Icon(Icons.straighten, color: AppColors.rose), title: Text("Retouches & Ajustements"), subtitle: Text("À partir de 5 000 FCFA")),
      ],
    );
  }

  // --- ONGLET : GALERIE ---
  Widget _buildGalleryTab(List<ArticleModel> articles) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
      itemCount: articles.length,
      itemBuilder: (context, index) => ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(articles[index].imageUrl, fit: BoxFit.cover)),
    );
  }

  // --- ONGLET : AVIS ---
  Widget _buildReviewsTab(List<dynamic> reviews) {
    if (reviews.isEmpty) return const Center(child: Text("Aucun avis client."));
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: reviews.length,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          title: Text(reviews[index].userNom, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(reviews[index].commentaire),
          trailing: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star, color: Colors.amber, size: 14), Text("5/5")]),
        ),
      ),
    );
  }

  // --- FONCTION : CHAT ---
  void _startChat() async {
    final user = await _auth.onAuthStateChanged.first;
    if (user != null) {
      final convId = await ChatService().getOrCreateConversation(
        client: user,
        prestataireId: widget.prestataireId,
        prestataireNom: widget.nom,
        prestatairePhoto: widget.photoUrl,
      );
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatConversationScreen(conversationId: convId, pName: widget.nom, pPhoto: widget.photoUrl, prestataireVerified: widget.isVerified)));
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(context, shrinkOffset, overlapsContent) => Container(color: Colors.white, child: _tabBar);
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
