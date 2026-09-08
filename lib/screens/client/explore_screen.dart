
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/article_model.dart';
import '../../services/dashboard_service.dart';
import '../article_detail_screen.dart';
import 'virtual_try_on_screen.dart';

class ExploreScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ExploreScreen({super.key, this.onBack});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final DashboardService _service = DashboardService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedTag = "Tous";

  final List<String> _trendingTags = [
    "Tous",
    "#WaxModerne",
    "#KnotlessBraids",
    "#MariageAfricain",
    "#NappyQueen",
    "#ToghuRoyale",
    "#BazinRiche",
    "#AfroChic",
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        List<ArticleModel> list = _service.articles;

        if (_selectedTag != "Tous") {
          final cleanTag = _selectedTag.replaceAll("#", "").toLowerCase();
          list = list.where((a) {
            return a.tags.any((t) => t.toLowerCase().contains(cleanTag)) ||
                a.categorie.toLowerCase().contains(cleanTag) ||
                a.titre.toLowerCase().contains(cleanTag);
          }).toList();
        }

        final query = _searchController.text.trim().toLowerCase();
        if (query.isNotEmpty) {
          list = list.where((a) =>
              a.titre.toLowerCase().contains(query) ||
              a.prestataireNom.toLowerCase().contains(query) ||
              a.categorie.toLowerCase().contains(query)).toList();
        }

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
              "Explorer & Tendances",
              style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              // Champ de recherche
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Rechercher créations, coiffures, mots-clés...",
                        prefixIcon: const Icon(Icons.search, color: AppColors.rose),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
              ),

              // Tags tendances
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _trendingTags.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tag = _trendingTags[index];
                      final isSelected = _selectedTag == tag;
                      return ChoiceChip(
                        label: Text(tag),
                        selected: isSelected,
                        selectedColor: AppColors.rose,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.noir,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: isSelected ? AppColors.rose : AppColors.ligne),
                        onSelected: (val) {
                          if (val) setState(() => _selectedTag = tag);
                        },
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Grille de découverte
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("${art.prix.toInt()} FCFA", style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.w900, fontSize: 12)),
                                            Row(
                                              children: [
                                                const Icon(Icons.favorite, color: AppColors.rose, size: 12),
                                                const SizedBox(width: 2),
                                                Text("${art.likesCount}", style: const TextStyle(fontSize: 11, color: AppColors.texteSecondaire)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Quick try-on icon button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 15),
                                    tooltip: "Essayer virtuellement",
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => VirtualTryOnScreen(article: art)),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: list.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }
}
