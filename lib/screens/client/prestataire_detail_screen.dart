
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/article_model.dart';
import '../../services/dashboard_service.dart';
import '../article_detail_screen.dart';
import 'booking_dialog.dart';
import 'chat_conversation_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: AppColors.noir,
                  leading: CircleAvatar(
                    backgroundColor: Colors.white70,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.noir),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    CircleAvatar(
                      backgroundColor: Colors.white70,
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? AppColors.rose : AppColors.noir,
                        ),
                        onPressed: () => _service.toggleFavoritePrestataire(widget.prestataireId),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(color: Colors.grey[800]),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black26, Colors.black.withOpacity(0.8)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundImage: NetworkImage(widget.photoUrl),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.nom,
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.noir),
                                        ),
                                      ),
                                      if (widget.isVerified) ...[
                                        const SizedBox(width: 6),
                                        const Icon(Icons.verified, color: Colors.blue, size: 20),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${widget.rating} (${widget.avisCount} avis clients)",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: AppColors.rose, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${widget.adresse} • ${widget.distance}",
                                        style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Badges de qualification
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (widget.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.shield_outlined, color: Colors.blue, size: 14),
                                    SizedBox(width: 4),
                                    Text("Prestataire certifié CAMERMODE", style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            if (widget.offersHomeService)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.succes.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.succes.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.home_repair_service, color: AppColors.succes, size: 14),
                                    SizedBox(width: 4),
                                    Text("Prestation à domicile disponible", style: TextStyle(color: AppColors.succes, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Boutons d'action principaux : Contacter & Réserver
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final convId = _service.getOrCreateConversation(
                                    prestataireId: widget.prestataireId,
                                    prestataireNom: widget.nom,
                                    prestatairePhoto: widget.photoUrl,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatConversationScreen(
                                        conversationId: convId,
                                        prestataireNom: widget.nom,
                                        prestatairePhoto: widget.photoUrl,
                                        prestataireVerified: widget.isVerified,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline, color: AppColors.noir, size: 18),
                                label: const Text("Contacter", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: AppColors.ligne),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (providerArticles.isNotEmpty) {
                                    BookingDialog.show(context, providerArticles.first);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Sélectionnez une création pour réserver.")),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.calendar_month, color: Colors.white, size: 18),
                                label: const Text("Réserver", style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.rose,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.rose,
                      unselectedLabelColor: AppColors.texteSecondaire,
                      indicatorColor: AppColors.rose,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: "Créations"),
                        Tab(text: "Services"),
                        Tab(text: "Galerie"),
                        Tab(text: "Avis vérifiés"),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // 1. Articles publiés
                providerArticles.isEmpty
                    ? const Center(child: Text("Aucune création publiée"))
                    : GridView.builder(
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
                              child: Column(
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
                                        const SizedBox(height: 4),
                                        Text("${art.prix.toInt()} FCFA", style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.w900, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                // 2. Services proposés
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildServiceCard(context, "Confection sur-mesure", "Prise de mesures, coupe, essayage intermédiaire et finitions", "À partir de 35 000 FCFA", Icons.straighten, providerArticles.firstOrNull),
                    _buildServiceCard(context, "Retouche & Ajustement", "Ajustements d'ourlets, cintrage et reprises de robes/vestes", "À partir de 10 000 FCFA", Icons.cut, providerArticles.firstOrNull),
                    _buildServiceCard(context, "Stylisme & Conseil Mode", "Accompagnement personnalisé pour choix de tissus et modèles", "20 000 FCFA / séance", Icons.auto_awesome, providerArticles.firstOrNull),
                  ],
                ),

                // 3. Galerie
                GridView.builder(
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
                ),

                // 4. Avis Vérifiés
                reviews.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text("Les avis clients apparaîtront dès la réalisation de prestations vérifiées."),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final r = reviews[index];
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: AppColors.ligne),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 16,
                                        backgroundColor: AppColors.roseClair,
                                        child: Icon(Icons.person, color: AppColors.noir, size: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(r.userNom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                const SizedBox(width: 6),
                                                const Icon(Icons.verified, color: Colors.green, size: 14),
                                                const SizedBox(width: 4),
                                                const Text("Client vérifié", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            Text(r.serviceTitre, style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(5, (i) => Icon(Icons.star, color: Colors.amber, size: 14)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(r.commentaire, style: const TextStyle(fontSize: 13, height: 1.4)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, String titre, String desc, String tarif, IconData icon, ArticleModel? fallbackArticle) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.ligne),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: AppColors.rose.withOpacity(0.12),
          child: Icon(icon, color: AppColors.rose),
        ),
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
            if (fallbackArticle != null) {
              BookingDialog.show(context, fallbackArticle);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.noir,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Réserver", style: TextStyle(fontSize: 12)),
        ),
      ),
    );
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
