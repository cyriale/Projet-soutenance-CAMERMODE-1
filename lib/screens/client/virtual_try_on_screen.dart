import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/huggingface_tryon_service.dart';
import '../../models/article_model.dart';
import '../../services/dashboard_service.dart';

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
  // COULEURS DE L'INTERFACE
  // =========================================================

  static const Color _background = Color(0xFFF8F4F5);
  static const Color _surface = Color(0xFFFFFBFC);

  static const Color _softRose = Color(0xFFC98794);
  static const Color _darkRose = Color(0xFF9F606D);

  static const Color _textPrimary = Color(0xFF40373A);
  static const Color _textSecondary = Color(0xFF827579);

  static const Color _border = Color(0xFFEADFE2);
  static const Color _softContainer = Color(0xFFF2E7EA);
  static const Color _success = Color(0xFF4F8A6E);


  // =========================================================
  // PHOTO / MANNEQUIN
  // =========================================================

  bool _usePersonalPhoto = false;

  XFile? _personalImage;
  Uint8List? _personalImageBytes;

  int _selectedMannequinIndex = 0;

  final ImagePicker _picker = ImagePicker();

  // =========================================================
  // ARTICLE
  // =========================================================

  late String _selectedColor;
  late String _selectedSize;

  // =========================================================
  // POSITION / ZOOM DU VÊTEMENT
  // =========================================================

  Offset _overlayOffset = Offset.zero;

  double _overlayScale = 1.0;

  double _gestureStartScale = 1.0;

  final double _overlayOpacity = 0.96;


  final HuggingFaceTryOnService _tryOnAi =
  HuggingFaceTryOnService();

  bool _isGeneratingAi = false;

  Uint8List? _aiResultBytes;

  String? _aiError;

  // =========================================================
  // MANNEQUINS
  // =========================================================

  final List<Map<String, String>> _mannequins = [
    {
      "name": "Morphologie X",
      "subtitle": "Sablier",
      "url":
      "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=900&q=85",
    },
    {
      "name": "Morphologie H",
      "subtitle": "Rectangle",
      "url":
      "https://images.unsplash.com/photo-1589156280159-27698a70f29e?auto=format&fit=crop&w=900&q=85",
    },
    {
      "name": "Morphologie A",
      "subtitle": "Pyramide",
      "url":
      "https://images.unsplash.com/photo-1523824921871-d6f1a15151f1?auto=format&fit=crop&w=900&q=85",
    },
    {
      "name": "Homme",
      "subtitle": "Athlétique",
      "url":
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=900&q=85",
    },
  ];

  // =========================================================
  // MAPPING COULEURS
  // =========================================================

  final Map<String, Color> _colorMap = {
    "Noir": const Color(0xFF222222),
    "Blanc": const Color(0xFFF5F5F5),
    "Rouge": const Color(0xFFC95E65),
    "Bleu": const Color(0xFF6688A6),
    "Vert": const Color(0xFF72947A),
    "Jaune": const Color(0xFFE5C56B),
    "Or": const Color(0xFFD2A85F),
    "Bordeaux": const Color(0xFF8E5967),
    "Rose": const Color(0xFFD796A3),
    "Beige": const Color(0xFFD8C6AF),
    "Marron": const Color(0xFF8D7063),
    "Gris": const Color(0xFF949094),
  };

  // =========================================================
  // INITIALISATION
  // =========================================================

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

  Future<void> _generateAiTryOn() async {
    // ==========================================
    // Vérifier la photo
    // ==========================================

    if (_personalImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Importez d'abord votre photo.",
          ),
        ),
      );

      return;
    }

    setState(() {
      _isGeneratingAi = true;
      _aiError = null;
    });

    try {
      final Uint8List result =
      await _tryOnAi.generateTryOn(
        personImage:
        _personalImageBytes!,

        garmentImageUrl:
        widget.article.imageUrl,

        garmentDescription:
        widget.article.titre,

        autoMask: true,

        autoCrop: true,

        denoiseSteps: 30,

        seed: 42,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _aiResultBytes = result;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _aiError = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Essayage IA impossible : $e",
          ),
          duration:
          const Duration(seconds: 8),
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

  Widget _buildGeneratingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.78),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 0.85,
                  end: 1.15,
                ),
                duration: const Duration(
                  milliseconds: 900,
                ),
                curve: Curves.easeInOut,
                builder: (
                    context,
                    value,
                    child,
                    ) {
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
                    color: const Color(0xFFF2E7EA),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9F606D)
                            .withOpacity(0.18),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 34,
                    color: Color(0xFF9F606D),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                "Création de votre essayage",
                style: TextStyle(
                  color: Color(0xFF40373A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "L'intelligence artificielle prépare votre rendu",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF827579),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 18),

              const SizedBox(
                width: 150,
                child: LinearProgressIndicator(
                  minHeight: 4,
                  color: Color(0xFF9F606D),
                  backgroundColor: Color(0xFFEADFE2),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
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

        // Taille raisonnable pour éviter de charger une photo de 10-20 Mo.
        maxWidth: 1600,

        imageQuality: 90,
      );

      if (file == null) {
        return;
      }

      // Fonctionne sur Android / iOS / Web.
      //
      // Contrairement à Image.network(file.path), nous lisons réellement
      // le contenu du fichier sélectionné.
      final Uint8List bytes = await file.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        _personalImage = file;
        _personalImageBytes = bytes;

        _usePersonalPhoto = true;

        // Réinitialisation automatique du vêtement.
        _resetOverlay();
      });
    } catch (e, stackTrace) {
      debugPrint("Erreur import photo : $e");
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Impossible de charger cette photo.",
          ),
        ),
      );
    }
  }

  // =========================================================
  // RESET POSITION
  // =========================================================

  void _resetOverlay() {
    _overlayOffset = Offset.zero;
    _overlayScale = 1.0;
    _gestureStartScale = 1.0;
  }

  // =========================================================
  // GESTURES
  // =========================================================

  void _onScaleStart(ScaleStartDetails details) {
    _gestureStartScale = _overlayScale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Déplacement avec un ou plusieurs doigts.
      _overlayOffset += details.focalPointDelta;

      // Zoom tactile.
      if (details.pointerCount > 1) {
        _overlayScale = (_gestureStartScale * details.scale)
            .clamp(0.55, 2.0)
            .toDouble();
      }
    });
  }

  // =========================================================
  // COULEUR DE L'ARTICLE
  // =========================================================

  Color _getOverlayFilterColor() {
    for (final entry in _colorMap.entries) {
      if (_selectedColor
          .toLowerCase()
          .contains(entry.key.toLowerCase())) {
        return entry.value.withOpacity(0.28);
      }
    }

    return Colors.transparent;
  }

  // =========================================================
  // PHOTO PRINCIPALE
  // =========================================================

  Widget _buildPersonImage() {
    // -------------------------------------------------------
    // Photo personnelle
    // -------------------------------------------------------

    if (_usePersonalPhoto && _personalImageBytes != null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF1EDEE),
        alignment: Alignment.center,
        child: Image.memory(
          _personalImageBytes!,
          width: double.infinity,
          height: double.infinity,

          // Important :
          // l'image reste entièrement visible sans déformation.
          fit: BoxFit.contain,

          gaplessPlayback: true,
          filterQuality: FilterQuality.high,

          errorBuilder: (_, __, ___) {
            return const _ImageErrorPlaceholder(
              message: "Impossible d'afficher votre photo",
            );
          },
        ),
      );
    }

    // -------------------------------------------------------
    // Mannequin distant
    // -------------------------------------------------------

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF1EDEE),
      child: Image.network(
        _mannequins[_selectedMannequinIndex]["url"]!,
        width: double.infinity,
        height: double.infinity,

        fit: BoxFit.contain,

        filterQuality: FilterQuality.high,

        loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? progress,
            ) {
          if (progress == null) {
            return child;
          }

          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _softRose,
            ),
          );
        },

        errorBuilder: (_, __, ___) {
          return const _ImageErrorPlaceholder(
            message: "Mannequin indisponible",
          );
        },
      ),
    );
  }

  // =========================================================
  // IMAGE ARTICLE
  // =========================================================

  Widget _buildArticleImage() {
    Widget image = Image.network(
      widget.article.imageUrl,
      width: double.infinity,
      height: double.infinity,

      // Important :
      // évite de couper les manches / coiffures / robe.
      fit: BoxFit.contain,

      filterQuality: FilterQuality.high,

      loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? progress,
          ) {
        if (progress == null) {
          return child;
        }

        return const Center(
          child: CircularProgressIndicator(
            color: _softRose,
            strokeWidth: 2,
          ),
        );
      },

      errorBuilder: (_, __, ___) {
        return const Center(
          child: Icon(
            Icons.checkroom_outlined,
            size: 65,
            color: _darkRose,
          ),
        );
      },
    );

    final Color filterColor = _getOverlayFilterColor();

    if (filterColor != Colors.transparent) {
      image = ColorFiltered(
        colorFilter: ColorFilter.mode(
          filterColor,
          BlendMode.color,
        ),
        child: image,
      );
    }

    return image;
  }

  // =========================================================
  // CANVAS ESSAYAGE
  // =========================================================

  Widget _buildTryOnCanvas({
    required bool isCouture,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool hasPersonalPhoto =
            _usePersonalPhoto && _personalImageBytes != null;

        // =====================================================
        // AVANT IMPORT : UNE SEULE ZONE
        // =====================================================

        if (!hasPersonalPhoto) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFF4F0F1),
            child: Stack(
              children: [
                // Article au centre
                Positioned.fill(
                  child: Center(
                    child: _buildArticlePreview(
                      isCouture: isCouture,
                      maxWidth: constraints.maxWidth,
                      maxHeight: constraints.maxHeight,
                    ),
                  ),
                ),

                // Guide
                Positioned(
                  top: 12,
                  left: 14,
                  right: 14,
                  child: _buildTryOnGuide(),
                ),
              ],
            ),
          );
        }


        // =====================================================
        // APRÈS IMPORT : DEUX ZONES
        // =====================================================

        final bool useVerticalLayout =
            constraints.maxWidth < 600;

        if (useVerticalLayout) {
          // Téléphone étroit :
          // photo en haut + article en bas
          return Column(
            children: [
              Expanded(
                child: _buildPersonalPhotoPanel(),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: _buildArticlePanel(
                  isCouture: isCouture,
                ),
              ),
            ],
          );
        }

        // Tablette / écran large :
        // photo à gauche + article à droite
        return Row(
          children: [
            Expanded(
              child: _buildPersonalPhotoPanel(),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _buildArticlePanel(
                isCouture: isCouture,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTryOnGuide() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 15,
              color: Color(0xFF9F606D),
            ),
            SizedBox(width: 6),
            Text(
              "Glissez • pincez pour zoomer",
              style: TextStyle(
                color: Color(0xFF40373A),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPersonalPhotoPanel() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEADFE2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.memory(
              _personalImageBytes!,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),

          Positioned(
            top: 10,
            left: 10,
            child: _buildPanelLabel(
              icon: Icons.person_outline,
              text: "Ma photo",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlePanel({
    required bool isCouture,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFEADFE2),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: _buildArticlePreview(
                    isCouture: isCouture,
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                  ),
                ),
              ),

              Positioned(
                top: 10,
                left: 10,
                child: _buildPanelLabel(
                  icon: isCouture
                      ? Icons.checkroom_outlined
                      : Icons.face_retouching_natural,
                  text: isCouture
                      ? "Article"
                      : "Coiffure",
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  tooltip: "Réinitialiser",
                  onPressed: () {
                    setState(_resetOverlay);
                  },
                  icon: const Icon(
                    Icons.restart_alt,
                    color: Color(0xFF9F606D),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArticlePreview({
    required bool isCouture,
    required double maxWidth,
    required double maxHeight,
  }) {
    final double articleWidth = isCouture
        ? math.min(maxWidth * 0.72, 300.0)
        : math.min(maxWidth * 0.62, 220.0);

    final double articleHeight = isCouture
        ? math.min(maxHeight * 0.72, 390.0)
        : math.min(maxHeight * 0.55, 240.0);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,

      onScaleStart: _onScaleStart,

      onScaleUpdate: _onScaleUpdate,

      child: Transform.translate(
        offset: _overlayOffset,
        child: Transform.scale(
          scale: _overlayScale,
          child: SizedBox(
            width: articleWidth,
            height: articleHeight,
            child: _buildArticleImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelLabel({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF9F606D),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF40373A),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  // =========================================================
  // IMPORT PHOTO BOTTOM SHEET
  // =========================================================

  void _showPhotoPicker() {
    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.transparent,

      isScrollControlled: true,

      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              24,
              16,
              24,
              28,
            ),
            decoration: const BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                const Icon(
                  Icons.add_a_photo_outlined,
                  size: 38,
                  color: _softRose,
                ),

                const SizedBox(height: 12),

                const Text(
                  "Essayer avec ma photo",
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Choisissez une photo où votre silhouette est bien visible.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _softContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: _darkRose,
                        size: 17,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Votre photo reste privée sur votre appareil.",
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _PhotoSourceButton(
                  icon: Icons.camera_alt_outlined,
                  title: "Prendre une photo",
                  subtitle: "Utiliser la caméra",
                  onTap: () {
                    Navigator.pop(context);

                    _pickImage(
                      ImageSource.camera,
                    );
                  },
                ),

                const SizedBox(height: 10),

                _PhotoSourceButton(
                  icon: Icons.photo_library_outlined,
                  title: "Choisir dans la galerie",
                  subtitle: "Importer une photo existante",
                  onTap: () {
                    Navigator.pop(context);

                    _pickImage(
                      ImageSource.gallery,
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

  // =========================================================
  // MODÈLES
  // =========================================================

  Widget _buildModelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: _SectionTitle(
                title: "MODÈLE",
              ),
            ),

            TextButton.icon(
              onPressed: _showPhotoPicker,
              icon: const Icon(
                Icons.add_a_photo_outlined,
                size: 17,
              ),
              label: Text(
                _personalImage == null
                    ? "Ma photo"
                    : "Changer",
              ),
              style: TextButton.styleFrom(
                foregroundColor: _darkRose,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            itemCount: _mannequins.length +
                (_personalImage != null ? 1 : 0),

            separatorBuilder: (_, __) {
              return const SizedBox(width: 8);
            },

            itemBuilder: (
                BuildContext context,
                int index,
                ) {
              // ----------------------------------------------
              // PHOTO PERSONNELLE
              // ----------------------------------------------

              if (_personalImage != null && index == 0) {
                return ChoiceChip(
                  avatar: const Icon(
                    Icons.person_pin_outlined,
                    size: 17,
                  ),

                  label: const Text(
                    "Ma photo",
                  ),

                  selected: _usePersonalPhoto,

                  selectedColor: _softContainer,

                  backgroundColor:
                  const Color(0xFFF7F2F3),

                  side: BorderSide(
                    color: _usePersonalPhoto
                        ? _softRose
                        : _border,
                  ),

                  labelStyle: TextStyle(
                    color: _usePersonalPhoto
                        ? _darkRose
                        : _textSecondary,
                    fontSize: 12,
                    fontWeight: _usePersonalPhoto
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),

                  onSelected: (_) {
                    setState(() {
                      _usePersonalPhoto = true;

                      _resetOverlay();
                    });
                  },
                );
              }

              // ----------------------------------------------
              // MANNEQUINS
              // ----------------------------------------------

              final int mannequinIndex =
              _personalImage != null
                  ? index - 1
                  : index;

              final bool selected =
                  !_usePersonalPhoto &&
                      _selectedMannequinIndex ==
                          mannequinIndex;

              return ChoiceChip(
                label: Text(
                  _mannequins[mannequinIndex]["name"]!,
                ),

                selected: selected,

                selectedColor: _softContainer,

                backgroundColor:
                const Color(0xFFF7F2F3),

                side: BorderSide(
                  color:
                  selected ? _softRose : _border,
                ),

                labelStyle: TextStyle(
                  color: selected
                      ? _darkRose
                      : _textSecondary,
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),

                onSelected: (_) {
                  setState(() {
                    _selectedMannequinIndex =
                        mannequinIndex;

                    _usePersonalPhoto = false;

                    _resetOverlay();
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
  // COULEURS
  // =========================================================

  Widget _buildColorSelector() {
    if (widget.article.couleursDisponibles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionTitle(
              title: "COULEUR",
            ),

            const SizedBox(width: 8),

            Text(
              _selectedColor,
              style: const TextStyle(
                color: _darkRose,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,

            children: widget.article.couleursDisponibles
                .map(
                  (String colorName) {
                final bool selected =
                    _selectedColor == colorName;

                Color displayColor =
                const Color(0xFFB0A6A9);

                for (final entry
                in _colorMap.entries) {
                  if (colorName
                      .toLowerCase()
                      .contains(
                    entry.key.toLowerCase(),
                  )) {
                    displayColor = entry.value;
                    break;
                  }
                }

                return Padding(
                  padding:
                  const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: displayColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black
                              .withOpacity(0.08),
                        ),
                      ),
                    ),

                    label: Text(
                      colorName,
                    ),

                    selected: selected,

                    selectedColor:
                    _softRose.withOpacity(0.13),

                    backgroundColor:
                    const Color(0xFFF7F2F3),

                    checkmarkColor: _darkRose,

                    side: BorderSide(
                      color: selected
                          ? _softRose
                          : _border,
                    ),

                    labelStyle: TextStyle(
                      color: selected
                          ? _darkRose
                          : _textSecondary,
                      fontSize: 11,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),

                    onSelected: (bool value) {
                      if (!value) {
                        return;
                      }

                      setState(() {
                        _selectedColor =
                            colorName;
                      });
                    },
                  ),
                );
              },
            ).toList(),
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
        const _SectionTitle(
          title: "TAILLE",
        ),

        const SizedBox(height: 9),

        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            itemCount:
            widget.article.taillesDisponibles.length,

            separatorBuilder: (_, __) {
              return const SizedBox(width: 8);
            },

            itemBuilder: (
                BuildContext context,
                int index,
                ) {
              final String size =
              widget.article.taillesDisponibles[index];

              final bool selected =
                  size == _selectedSize;

              return ChoiceChip(
                label: Text(size),

                selected: selected,

                selectedColor:
                _softRose.withOpacity(0.15),

                backgroundColor:
                const Color(0xFFF7F2F3),

                side: BorderSide(
                  color:
                  selected ? _softRose : _border,
                ),

                labelStyle: TextStyle(
                  color: selected
                      ? _darkRose
                      : _textSecondary,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
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
  // ZOOM
  // =========================================================

  Widget _buildZoomControl() {
    return Row(
      children: [
        const Icon(
          Icons.zoom_out,
          color: _textSecondary,
          size: 20,
        ),

        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape:
              const RoundSliderThumbShape(
                enabledThumbRadius: 7,
              ),
            ),
            child: Slider(
              value: _overlayScale,

              min: 0.55,
              max: 2,

              activeColor: _softRose,

              inactiveColor: _border,

              onChanged: (double value) {
                setState(() {
                  _overlayScale = value;
                });
              },
            ),
          ),
        ),

        const Icon(
          Icons.zoom_in,
          color: _textSecondary,
          size: 20,
        ),

        const SizedBox(width: 8),

        Text(
          "${(_overlayScale * 100).round()}%",
          style: const TextStyle(
            color: _textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // PANNEAU DU BAS
  // =========================================================

  Widget _buildControlPanel() {
    return Container(
      width: double.infinity,

      decoration: const BoxDecoration(
        color: _surface,

        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),

        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          18,
          14,
          18,
          18,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poignée
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 10),

            _buildModelSelector(),

            const SizedBox(height: 16),

            _buildColorSelector(),

            if (widget.article
                .couleursDisponibles.isNotEmpty)
              const SizedBox(height: 16),

            _buildSizeSelector(),

            if (widget.article
                .taillesDisponibles.isNotEmpty)
              const SizedBox(height: 14),

            const _SectionTitle(
              title: "AJUSTEMENT",
            ),

            const SizedBox(height: 4),

            _buildZoomControl(),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isGeneratingAi
                    ? null
                    : _generateAiTryOn,

                icon: _isGeneratingAi
                    ? const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.auto_awesome,
                ),

                label: Text(
                  _isGeneratingAi
                      ? "Création de votre essayage..."
                      : "Essayer avec l'IA",
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF9F606D),
                  foregroundColor:
                  Colors.white,
                  disabledBackgroundColor:
                  const Color(0xFFC7A9AF),

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saveAndExport,

                icon: const Icon(
                  Icons.download_outlined,
                  size: 19,
                ),

                label: const Text(
                  "Enregistrer mon essayage",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: _softRose,
                  foregroundColor: Colors.white,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SAUVEGARDE
  // =========================================================


  Widget _buildAiResult() {
    if (_aiResultBytes == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: const Color(0xFFF4F0F1),

            child: Image.memory(
              _aiResultBytes!,
              fit: BoxFit.contain,
              filterQuality:
              FilterQuality.high,
            ),
          ),
        ),

        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),

            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.92),

              borderRadius:
              BorderRadius.circular(20),
            ),

            child: const Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 15,
                  color:
                  Color(0xFF9F606D),
                ),

                SizedBox(width: 6),

                Text(
                  "Essayage généré par IA",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            tooltip:
            "Retour à l'édition",

            onPressed: () {
              setState(() {
                _aiResultBytes = null;
              });
            },

            icon: const Icon(
              Icons.close,
            ),
          ),
        ),
      ],
    );
  }


  void _saveAndExport() {
    final DashboardService service =
    DashboardService();

    service.saveTryOnResult(
      articleId: widget.article.id,
      articleTitre: widget.article.titre,
      colorName: _selectedColor,
      size: _selectedSize,
      imageUrl: widget.article.imageUrl,
    );

    showDialog(
      context: context,

      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _surface,

          surfaceTintColor: Colors.transparent,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: _success,
                size: 28,
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  "Essayage enregistré",
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              const Text(
                "Votre visualisation a été enregistrée dans votre espace personnel.",
                style: TextStyle(
                  color: _textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: _softContainer,

                  borderRadius:
                  BorderRadius.circular(14),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      widget.article.titre,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Couleur : $_selectedColor",
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      "Taille : $_selectedSize",
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Fermer",
                style: TextStyle(
                  color: _textSecondary,
                ),
              ),
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(this.context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Essayage enregistré avec succès.",
                    ),
                  ),
                );
              },

              icon: const Icon(
                Icons.check,
                size: 17,
              ),

              label: const Text(
                "Terminer",
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: _softRose,
                foregroundColor: Colors.white,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final bool isCouture =
        widget.article.type == ArticleType.couture;

    return Scaffold(
      backgroundColor: _background,

      // =====================================================
      // APPBAR
      // =====================================================

      appBar: AppBar(
        backgroundColor: _surface,

        surfaceTintColor: Colors.transparent,

        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: _textPrimary,
            size: 20,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        titleSpacing: 4,

        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Text(
              isCouture
                  ? "Essayage virtuel"
                  : "Coiffure virtuelle",

              style: const TextStyle(
                color: _textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 1),

            const Text(
              "Visualisez votre style",

              style: TextStyle(
                color: _textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: "Réinitialiser",

            icon: const Icon(
              Icons.restart_alt,
              color: _textSecondary,
            ),

            onPressed: () {
              setState(_resetOverlay);
            },
          ),

          IconButton(
            tooltip: "Enregistrer",

            icon: const Icon(
              Icons.download_outlined,
              color: _darkRose,
            ),

            onPressed: _saveAndExport,
          ),

          const SizedBox(width: 4),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SafeArea(
        top: false,

        child: Column(
          children: [
            // =================================================
            // BANDEAU CONFIDENTIALITÉ
            // =================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 9,
              ),

              color: _softContainer,

              child: const Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: _darkRose,
                    size: 16,
                  ),

                  SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      "Votre photo reste privée sur votre appareil",
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // CANVAS PHOTO
            // =================================================

            Expanded(
              flex: 7,

              child: Container(
                margin: const EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  8,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFF1EDEE),

                  borderRadius:
                  BorderRadius.circular(24),

                  border: Border.all(
                    color: _border,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                clipBehavior: Clip.antiAlias,

                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _aiResultBytes != null
                          ? _buildAiResult()
                          : _buildTryOnCanvas(
                        isCouture: isCouture,
                      ),
                    ),

                    if (_isGeneratingAi)
                      _buildGeneratingOverlay(),
                  ],
                ),
              ),
            ),

            // =================================================
            // CONTRÔLES
            // =================================================

            Flexible(
              flex: 5,
              child: _buildControlPanel(),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// PETIT TITRE DE SECTION
// ===========================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });
  static const Color _textSecondary = Color(0xFF827579);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _textSecondary,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }
}

// ===========================================================
// ERREUR IMAGE
// ===========================================================

class _ImageErrorPlaceholder extends StatelessWidget {
  final String message;

  const _ImageErrorPlaceholder({
    required this.message,
  });

  static const Color _softRose = Color(0xFFC98794);
  static const Color _textSecondary = Color(0xFF827579);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: _softRose,
            ),

            const SizedBox(height: 10),

            Text(
              message,

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: _textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// BOUTON SOURCE PHOTO
// ===========================================================

class _PhotoSourceButton extends StatelessWidget {
  final IconData icon;

  final String title;

  final String subtitle;

  final VoidCallback onTap;

  const _PhotoSourceButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const Color _darkRose = Color(0xFF9F606D);

  static const Color _textPrimary = Color(0xFF40373A);
  static const Color _textSecondary = Color(0xFF827579);

  static const Color _border = Color(0xFFEADFE2);
  static const Color _softContainer = Color(0xFFF2E7EA);


  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F2F3),

      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(16),

        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: _border,
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: _softContainer,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(
                  icon,
                  color: _darkRose,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,

                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: _textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}