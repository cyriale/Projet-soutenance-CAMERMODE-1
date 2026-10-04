import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/app_colors.dart';
import '../../models/article_model.dart';
import '../../services/dashboard_service.dart';
import '../../services/virtual_try_on_service.dart';
import '../../compronents/app_cached_image.dart';
import 'booking_dialog.dart';

class VirtualTryOnScreen extends StatefulWidget {
  final ArticleModel article;

  const VirtualTryOnScreen({
    super.key,
    required this.article,
  });

  @override
  State<VirtualTryOnScreen> createState() => _VirtualTryOnScreenState();
}

class _VirtualTryOnScreenState extends State<VirtualTryOnScreen> {
  // =========================================================
  // PHOTO DE L'UTILISATEUR (CÔTÉ 2)
  // =========================================================

  Uint8List? _personalImageBytes;

  final ImagePicker _picker = ImagePicker();

  // =========================================================
  // ARTICLE (CÔTÉ 1)
  // =========================================================

  late String _selectedColor;
  late String _selectedSize;

  double _overlayScale = 1.0;

  bool _isGeneratingAi = false;

  Uint8List? _aiResultBytes;

  // =========================================================
  // COULEURS DYNAMIQUES
  // =========================================================

  final Map<String, Color> _colorMap = {
    "Noir": Colors.black,
    "Blanc": Colors.white,
    "Rouge": const Color(0xFFD32F2F),
    "Bleu": const Color(0xFF1976D2),
    "Vert": const Color(0xFF388E3C),
    "Jaune": const Color(0xFFFBC02D),
    "Rose": const Color(0xFFE91E63),
    "Violet": const Color(0xFF7B1FA2),
    "Bordeaux": const Color(0xFF800020),
    "Orange": const Color(0xFFF57C00),
    "Marron": const Color(0xFF5D4037),
    "Gris": const Color(0xFF616161),
    "Or": const Color(0xFFFFD700),
  };

  @override
  void initState() {
    super.initState();

    _selectedColor = "Origine";

    _selectedSize = widget.article.taillesDisponibles.isNotEmpty
        ? widget.article.taillesDisponibles.first
        : "M";
  }

  Color _getSelectedColorValue() {
    for (final entry in _colorMap.entries) {
      if (_selectedColor.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return Colors.transparent;
  }

  Widget _buildDynamicArticleImage() {
    final Color selectedColorValue = _getSelectedColorValue();
    final bool isStandard = selectedColorValue == Colors.transparent ||
        _selectedColor.toLowerCase().contains("standard") ||
        _selectedColor.toLowerCase().contains("origine") ||
        _selectedColor.toLowerCase().contains("aucune");

    if (isStandard) {
      return Transform.scale(
        scale: _overlayScale,
        child: AppCachedImage(
          imageUrl: widget.article.imageUrl,
          fit: BoxFit.cover,
        ),
      );
    }

    return Transform.scale(
      scale: _overlayScale,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          selectedColorValue.withOpacity(0.42),
          BlendMode.color,
        ),
        child: AppCachedImage(
          imageUrl: widget.article.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // =========================================================
  // JUMELAGE ET ESSAYAGE IA (VÊTEMENTS ET COIFFURES)
  // =========================================================

  Future<void> _generateAiTryOn() async {
    if (_personalImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez importer ou prendre votre photo d'abord pour le Côté 2."),
        ),
      );
      _showPhotoSourceBottomSheet();
      return;
    }

    setState(() {
      _isGeneratingAi = true;
    });

    try {
      final categoryStr = widget.article.type == ArticleType.coiffure ? "coiffure" : "couture";

      final tryOnResult = await VirtualTryOnService().generateVirtualTryOnBytes(
        personImageBytes: _personalImageBytes!,
        garmentImageUrl: widget.article.imageUrl,
        articleTitle: widget.article.titre,
        category: categoryStr,
        selectedColor: _selectedColor,
      );

      if (!mounted) return;

      if (tryOnResult.success && tryOnResult.resultImageUrl != null) {
        final String rawUrl = tryOnResult.resultImageUrl!;
        Uint8List? decodedBytes;

        if (rawUrl.startsWith("data:image/")) {
          final String base64Data = rawUrl.contains(",") ? rawUrl.split(",").last : rawUrl;
          decodedBytes = base64Decode(base64Data);
        } else {
          final httpRes = await http.get(Uri.parse(rawUrl));
          if (httpRes.statusCode == 200) {
            decodedBytes = httpRes.bodyBytes;
          }
        }

        if (mounted && decodedBytes != null) {
          setState(() {
            _aiResultBytes = decodedBytes;
          });

          // Sauvegarde automatique dans l'historique d'essayages
          DashboardService().saveTryOnResult(
            articleId: widget.article.id,
            articleTitre: widget.article.titre,
            colorName: _selectedColor,
            size: _selectedSize,
            imageUrl: widget.article.imageUrl,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✨ ${tryOnResult.message}"),
              backgroundColor: AppColors.succes,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Jumelage IA impossible : ${tryOnResult.message}"),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'essayage : $e"),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingAi = false;
        });
      }
    }
  }

  // =========================================================
  // OVERLAY GENERATION
  // =========================================================

  Widget _buildGeneratingOverlay() {
    final bool isCoiffure = widget.article.type == ArticleType.coiffure;

    return Positioned.fill(
      child: Container(
        color: AppColors.blanc.withOpacity(0.88),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.85, end: 1.15),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                onEnd: () {
                  if (mounted && _isGeneratingAi) {
                    setState(() {});
                  }
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.roseClair,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.rose.withOpacity(0.18),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    isCoiffure ? Icons.face_retouching_natural : Icons.auto_awesome,
                    size: 34,
                    color: AppColors.rose,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                isCoiffure ? "Application de la coiffure sur votre tête..." : "Jumelage des 2 côtés par l'IA...",
                style: const TextStyle(
                  color: AppColors.textePrincipal,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isCoiffure
                    ? "L'IA Nano Banana 2 adapte les cheveux sur votre visage"
                    : "Création de votre affiche d'essayage sur-mesure",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.texteGris,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              const SizedBox(
                width: 150,
                child: LinearProgressIndicator(
                  minHeight: 4,
                  color: AppColors.rose,
                  backgroundColor: AppColors.roseClair,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 90,
      );

      if (file == null) return;

      final Uint8List bytes = await file.readAsBytes();

      if (!mounted) return;

      setState(() {
        _personalImageBytes = bytes;
        _aiResultBytes = null;
      });
    } catch (e, stackTrace) {
      debugPrint("Erreur import photo : $e");
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible de charger cette photo."),
        ),
      );
    }
  }

  // =========================================================
  // VUE CÔTÉ CÔTÉ (2 CÔTÉS : ARTICLE A GAUCHE + USER A DROITE)
  // =========================================================

  Widget _buildSplitTwoSidesView() {
    final bool isCoiffure = widget.article.type == ArticleType.coiffure;

    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // CÔTÉ 1 : L'ARTICLE SÉLECTIONNÉ (À GAUCHE - DYNAMIQUE AVEC COULEUR & ZOOM)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.blanc,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.rose.withOpacity(0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _buildDynamicArticleImage(),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.noir.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isCoiffure ? Icons.face : Icons.checkroom, color: AppColors.blanc, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            isCoiffure ? "Côté 1 : Coiffure" : "Côté 1 : Article",
                            style: const TextStyle(color: AppColors.blanc, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.article.titre,
                            style: const TextStyle(color: AppColors.blanc, fontWeight: FontWeight.bold, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "$_selectedColor • ${widget.article.prix.toInt()} FCFA",
                            style: const TextStyle(color: AppColors.rose, fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ICÔNE DU CENTRE DE JUMELAGE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: CircleAvatar(
              backgroundColor: AppColors.rose,
              radius: 18,
              child: const Icon(Icons.auto_awesome, color: AppColors.blanc, size: 18),
            ),
          ),

          // CÔTÉ 2 : LA PHOTO DU CLIENT (À DROITE)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.blanc,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.rose.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_personalImageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.memory(
                        _personalImageBytes!,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    InkWell(
                      onTap: () => _showPhotoSourceBottomSheet(),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.roseClair,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.blanc,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_a_photo, color: AppColors.rose, size: 28),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Côté 2",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textePrincipal),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Ajoutez votre photo",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10, color: AppColors.texteGris),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person, color: AppColors.blanc, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            _personalImageBytes != null ? "Côté 2 : Ma Photo 📸" : "Côté 2 : Votre Photo",
                            style: const TextStyle(color: AppColors.blanc, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: AppColors.rose,
                      radius: 16,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.camera_alt, color: AppColors.blanc, size: 16),
                        onPressed: () => _showPhotoSourceBottomSheet(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // RÉSULTAT AFFICHE JUMELÉE IA (AFFICHE SEULE EN GRAND)
  // =========================================================

  Widget _buildAiResult() {
    if (_aiResultBytes == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: AppColors.blanc,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(
                _aiResultBytes!,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.rose,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 15, color: AppColors.blanc),
                SizedBox(width: 6),
                Text(
                  "AFFICHE JUMELÉE IA",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.blanc),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: AppColors.noir.withOpacity(0.75),
            radius: 18,
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: "Retour à la vue 2 Côtés",
              onPressed: () {
                setState(() {
                  _aiResultBytes = null;
                });
              },
              icon: const Icon(Icons.close, color: AppColors.blanc, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // HISTORIQUE : DERNIERS ESSAIS (RECHARGEMENT & RÉESSAYAGE)
  // =========================================================

  Widget _buildRecentTryOnsSection() {
    final DashboardService service = DashboardService();
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final recentTryOns = service.savedTryOns;
        if (recentTryOns.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionTitle(title: "DERNIERS ESSAIS"),
                Text(
                  "${recentTryOns.length} enregistré(s)",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.texteGris,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recentTryOns.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final tryOn = recentTryOns[index];
                  final String imgUrl = tryOn['imageUrl'] ?? widget.article.imageUrl;
                  final String titre = tryOn['articleTitre'] ?? "Essayage";
                  final String color = tryOn['colorName'] ?? "";
                  final String size = tryOn['size'] ?? "";

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _loadRecentTryOn(tryOn),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 190,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.blanc,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.ligne),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AppCachedImage(
                                imageUrl: imgUrl,
                                width: 56,
                                height: 74,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    titre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.textePrincipal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.roseClair,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "$color • $size",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.rose,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Row(
                                    children: [
                                      Icon(Icons.refresh, size: 12, color: AppColors.rose),
                                      SizedBox(width: 3),
                                      Text(
                                        "Réessayer",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.rose,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _loadRecentTryOn(Map<String, dynamic> tryOn) {
    setState(() {
      if (tryOn['colorName'] != null) _selectedColor = tryOn['colorName'];
      if (tryOn['size'] != null) _selectedSize = tryOn['size'];
      _aiResultBytes = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Rechargement de l'essayage : ${tryOn['articleTitre']}"),
        backgroundColor: AppColors.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =========================================================
  // BOUTON IMPORT PHOTO DE L'UTILISATEUR
  // =========================================================

  Widget _buildPhotoImportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: "PHOTO DU CLIENT (CÔTÉ 2)"),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showPhotoSourceBottomSheet(),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.roseClair,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.rose.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.rose,
                  radius: 20,
                  child: Icon(
                    _personalImageBytes != null ? Icons.check : Icons.add_a_photo,
                    color: AppColors.blanc,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _personalImageBytes != null ? "Ma photo Côté 2 est prête 📸" : "Ajouter votre photo pour le Côté 2",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textePrincipal),
                      ),
                      Text(
                        _personalImageBytes != null
                            ? "Cliquez pour changer votre photo"
                            : "Prenez une photo ou choisissez dans la galerie",
                        style: const TextStyle(fontSize: 11, color: AppColors.texteGris),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.rose),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPhotoSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: AppColors.ligne, borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 16),
              const Text(
                "Source de votre photo",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textePrincipal),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.roseClair,
                  child: Icon(Icons.camera_alt, color: AppColors.rose),
                ),
                title: const Text("Prendre une photo (Caméra)"),
                subtitle: const Text("Utiliser l'appareil photo du téléphone"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.roseClair,
                  child: Icon(Icons.photo_library, color: AppColors.rose),
                ),
                title: const Text("Choisir dans la galerie"),
                subtitle: const Text("Importer une photo enregistrée"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // COULEURS DYNAMIQUES AVEC OPTION "AUCUNE / ORIGINE"
  // =========================================================

  Widget _buildColorSelector() {
    final List<String> allColors = [
      "Origine",
      ...widget.article.couleursDisponibles,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionTitle(title: "COULEUR SÉLECTIONNÉE"),
            Text(
              _selectedColor,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.rose),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: allColors.map((String colorName) {
              final bool selected = _selectedColor == colorName;
              Color displayColor = AppColors.roseClair;

              for (final entry in _colorMap.entries) {
                if (colorName.toLowerCase().contains(entry.key.toLowerCase())) {
                  displayColor = entry.value;
                  break;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: colorName.toLowerCase().contains("origine") || colorName.toLowerCase().contains("aucune")
                      ? const Icon(Icons.block, size: 16, color: AppColors.texteGris)
                      : Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: displayColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black.withOpacity(0.1)),
                          ),
                        ),
                  label: Text(colorName),
                  selected: selected,
                  selectedColor: AppColors.roseClair,
                  backgroundColor: AppColors.grisClair,
                  checkmarkColor: AppColors.rose,
                  side: BorderSide(color: selected ? AppColors.rose : AppColors.ligne, width: selected ? 1.5 : 1),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.rose : AppColors.texteGris,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (bool value) {
                    if (!value) return;
                    setState(() {
                      _selectedColor = colorName;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // TAILLES
  // =========================================================

  Widget _buildSizeSelector() {
    if (widget.article.taillesDisponibles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: "TAILLE"),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.article.taillesDisponibles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final String size = widget.article.taillesDisponibles[index];
              final bool selected = size == _selectedSize;

              return ChoiceChip(
                label: Text(size),
                selected: selected,
                selectedColor: AppColors.roseClair,
                backgroundColor: AppColors.grisClair,
                side: BorderSide(color: selected ? AppColors.rose : AppColors.ligne, width: selected ? 1.5 : 1),
                labelStyle: TextStyle(
                  color: selected ? AppColors.rose : AppColors.texteGris,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                onSelected: (_) {
                  setState(() {
                    _selectedSize = size;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // =========================================================
  // AJUSTEMENT & CONTROL DU ZOOM / DEZOOM
  // =========================================================

  Widget _buildZoomControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: "ZOOM & TAILLE DE L'ARTICLE (CÔTÉ 1)"),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.zoom_out, color: AppColors.texteGris, size: 20),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: _overlayScale,
                  min: 0.55,
                  max: 2.0,
                  activeColor: AppColors.rose,
                  inactiveColor: AppColors.ligne,
                  onChanged: (double value) {
                    setState(() {
                      _overlayScale = value;
                    });
                  },
                ),
              ),
            ),
            const Icon(Icons.zoom_in, color: AppColors.texteGris, size: 20),
            const SizedBox(width: 8),
            Text(
              "${(_overlayScale * 100).round()}%",
              style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // PANNEAU DU BAS RESPONSIVE (THÈME APPBALL / APPCOLORS)
  // =========================================================

  Widget _buildControlPanel() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poignée
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ligne,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // HISTORIQUE DES DERNIERS ESSAIS
            _buildRecentTryOnsSection(),

            // IMPORT PHOTO UTILISATEUR
            _buildPhotoImportSection(),
            const SizedBox(height: 16),

            // SÉLECTION COULEURS & TAILLES DYNAMIQUES
            _buildColorSelector(),
            if (widget.article.couleursDisponibles.isNotEmpty) const SizedBox(height: 16),

            _buildSizeSelector(),
            if (widget.article.taillesDisponibles.isNotEmpty) const SizedBox(height: 16),

            // CONTROL DU ZOOM ET DEZOOM
            _buildZoomControl(),
            const SizedBox(height: 16),

            // BOUTON PRINCIPAL : JUMELER LES 2 CÔTÉS PAR L'IA
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isGeneratingAi ? null : _generateAiTryOn,
                icon: _isGeneratingAi
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isGeneratingAi
                      ? "Jumelage en cours..."
                      : (_aiResultBytes != null ? "🔄 RÉGÉNÉRER L'AFFICHE JUMELÉE" : "✨ JUMELER LES 2 CÔTÉS PAR L'IA"),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rose,
                  foregroundColor: AppColors.blanc,
                  disabledBackgroundColor: AppColors.rose.withOpacity(0.5),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // BOUTON 2 : ENREGISTRER L'ESSAYAGE ET LA PHOTO EN GALERIE
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saveAndExport,
                icon: const Icon(Icons.download_outlined, size: 19),
                label: const Text(
                  "Enregistrer dans la Galerie & Essais",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roseClair,
                  foregroundColor: AppColors.rose,
                  elevation: 0,
                  side: const BorderSide(color: AppColors.rose),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // BOUTON 3 : RÉSERVER CHEZ LE PRESTATAIRE
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => BookingDialog.show(context, widget.article),
                icon: const Icon(Icons.calendar_month, size: 19),
                label: Text(
                  "Réserver chez ${widget.article.prestataireNom}",
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.noir,
                  foregroundColor: AppColors.blanc,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAndExport() async {
    // 1. Sauvegarde automatique in-app dans DashboardService
    DashboardService().saveTryOnResult(
      articleId: widget.article.id,
      articleTitre: widget.article.titre,
      colorName: _selectedColor,
      size: _selectedSize,
      imageUrl: widget.article.imageUrl,
    );

    // 2. Écriture directe du fichier image dans la Galerie Photos d'Android & Broadcast MediaScanner
    bool savedToGallery = false;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final picturesDir = Directory('/storage/emulated/0/Pictures/CamerMode');
        if (!picturesDir.existsSync()) {
          picturesDir.createSync(recursive: true);
        }
        final String fileName = "CamerMode_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final File file = File('${picturesDir.path}/$fileName');

        if (_aiResultBytes != null) {
          await file.writeAsBytes(_aiResultBytes!);
          savedToGallery = true;
        } else {
          final httpResponse = await http.get(Uri.parse(widget.article.imageUrl));
          if (httpResponse.statusCode == 200) {
            await file.writeAsBytes(httpResponse.bodyBytes);
            savedToGallery = true;
          }
        }

        if (savedToGallery) {
          try {
            await Process.run('am', [
              'broadcast',
              '-a',
              'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
              '-d',
              'file://${file.path}'
            ]);
          } catch (_) {}
        }
      } catch (e) {
        debugPrint("Erreur écriture galerie : $e");
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.blanc,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.succes, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Enregistré avec succès !",
                  style: TextStyle(color: AppColors.textePrincipal, fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                savedToGallery
                    ? "✨ L'image a été enregistrée dans vos Derniers Essais ET directement dans l'application Galerie Photos de votre téléphone (Dossier Pictures/CamerMode) !"
                    : "Votre visualisation a été enregistrée dans vos Derniers Essais dans l'application.",
                style: const TextStyle(color: AppColors.texteGris, height: 1.4, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.roseClair,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.article.titre,
                      style: const TextStyle(color: AppColors.textePrincipal, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text("Couleur : $_selectedColor • Taille : $_selectedSize", style: const TextStyle(color: AppColors.texteGris, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer", style: TextStyle(color: AppColors.texteGris)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text("✨ Photo disponible dans la Galerie de votre téléphone !"),
                    backgroundColor: AppColors.succes,
                  ),
                );
              },
              icon: const Icon(Icons.check, size: 17),
              label: const Text("Terminer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rose,
                foregroundColor: AppColors.blanc,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // BUILD PRINCIPAL ET SAFE AREA RESPONSIVE
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final bool isCouture = widget.article.type == ArticleType.couture;

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        backgroundColor: AppColors.blanc,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textePrincipal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCouture ? "Essayage virtuel" : "Coiffure virtuelle",
              style: const TextStyle(color: AppColors.textePrincipal, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 1),
            Text(
              "Jumelage 2 Côtés • ${widget.article.prestataireNom}",
              style: const TextStyle(color: AppColors.texteGris, fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (_aiResultBytes != null)
            IconButton(
              tooltip: "Mode 2 Côtés",
              icon: const Icon(Icons.compare, color: AppColors.rose),
              onPressed: () => setState(() => _aiResultBytes = null),
            ),
          IconButton(
            tooltip: "Enregistrer dans la Galerie",
            icon: const Icon(Icons.download_outlined, color: AppColors.rose),
            onPressed: _saveAndExport,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Bandeau de confidentialité
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.roseClair,
              child: const Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: AppColors.rose, size: 15),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Votre photo reste privée sur votre appareil",
                      style: TextStyle(color: AppColors.texteGris, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            // Canvas d'essayage principal (Flex 5)
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                decoration: BoxDecoration(
                  color: AppColors.blanc,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.ligne),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _aiResultBytes != null
                          ? _buildAiResult()
                          : _buildSplitTwoSidesView(),
                    ),
                    if (_isGeneratingAi) _buildGeneratingOverlay(),
                  ],
                ),
              ),
            ),

            // Panneau de contrôle bas scrollable (Flex 6)
            Flexible(
              flex: 6,
              child: _buildControlPanel(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.texteGris,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}
