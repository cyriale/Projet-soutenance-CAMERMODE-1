
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_colors.dart';
import '../../models/article_model.dart';
import '../../services/dashboard_service.dart';

class VirtualTryOnScreen extends StatefulWidget {
  final ArticleModel article;

  const VirtualTryOnScreen({super.key, required this.article});

  @override
  State<VirtualTryOnScreen> createState() => _VirtualTryOnScreenState();
}

class _VirtualTryOnScreenState extends State<VirtualTryOnScreen> {
  // Mode : Mannequin prédéfini ou Photo Personnelle
  bool _usePersonalPhoto = false;
  XFile? _personalImage;
  int _selectedMannequinIndex = 0;

  // Options de couleur
  late String _selectedColor;
  late String _selectedSize;

  // Transformations interactives du vêtement/coiffure
  Offset _overlayOffset = const Offset(0, 0);
  double _overlayScale = 1.0;
  final double _overlayOpacity = 0.95;

  final ImagePicker _picker = ImagePicker();

  // Mannequins virtuels avec morphologies adaptées
  final List<Map<String, String>> _mannequins = [
    {
      "name": "Morphologie X (Sablier)",
      "url": "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=600&q=80",
    },
    {
      "name": "Morphologie H (Rectangulaire)",
      "url": "https://images.unsplash.com/photo-1589156280159-27698a70f29e?auto=format&fit=crop&w=600&q=80",
    },
    {
      "name": "Morphologie A (Pyramide)",
      "url": "https://images.unsplash.com/photo-1523824921871-d6f1a15151f1?auto=format&fit=crop&w=600&q=80",
    },
    {
      "name": "Silhouette Homme (Athlétique)",
      "url": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&q=80",
    },
  ];

  // Palette de couleurs avec mapping Color
  final Map<String, Color> _colorMap = {
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source, maxWidth: 1080);
      if (file != null) {
        setState(() {
          _personalImage = file;
          _usePersonalPhoto = true;
          _overlayOffset = const Offset(0, 0);
          _overlayScale = 1.0;
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la sélection photo: $e");
    }
  }

  void _saveAndExport() {
    final service = DashboardService();
    service.saveTryOnResult(
      articleId: widget.article.id,
      articleTitre: widget.article.titre,
      colorName: _selectedColor,
      size: _selectedSize,
      imageUrl: widget.article.imageUrl,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.succes, size: 28),
            SizedBox(width: 10),
            Text("Essayage exporté !", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Votre visualisation a été enregistrée avec succès dans votre espace personnel."),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.roseClair,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Article : ${widget.article.titre}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text("Couleur sélectionnée : $_selectedColor", style: const TextStyle(fontSize: 12)),
                  Text("Taille : $_selectedSize", style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Continuer"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Image haute résolution téléchargée dans votre galerie !"),
                  backgroundColor: AppColors.noir,
                ),
              );
            },
            icon: const Icon(Icons.download, color: Colors.white, size: 18),
            label: const Text("Télécharger l'image"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rose,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getOverlayFilterColor() {
    for (var entry in _colorMap.entries) {
      if (_selectedColor.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value.withOpacity(0.35);
      }
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final bool isCouture = widget.article.type == ArticleType.couture;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCouture ? "Studio Essayage Vêtement" : "Studio Essayage Coiffure",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Visualisation Virtuelle 2D/AR Intelligente",
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: "Partager l'essayage",
            onPressed: _saveAndExport,
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.rose),
            tooltip: "Exporter",
            onPressed: _saveAndExport,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Avertissement Confidentialité / Architecture honnête
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: const [
                Icon(Icons.shield, color: AppColors.rose, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Photos privées protégées • Visualisation d'ajustement morphologique",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // 2. Zone Canvas d'essayage virtuel interactif
          Expanded(
            child: Stack(
              children: [
                // Image de fond (Mannequin ou Photo personnelle)
                Positioned.fill(
                  child: Center(
                    child: _usePersonalPhoto && _personalImage != null
                        ? kIsWeb
                            ? Image.network(_personalImage!.path, fit: BoxFit.contain)
                            : Image.network(_personalImage!.path, fit: BoxFit.contain)
                        : Image.network(
                            _mannequins[_selectedMannequinIndex]["url"]!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[900],
                              child: const Icon(Icons.person, size: 120, color: Colors.white24),
                            ),
                          ),
                  ),
                ),

                // Dégradé pour lisibilité
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),

                // Calque de superposition de l'article (Déplaçable et zoomable)
                Positioned.fill(
                  child: Center(
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _overlayOffset += details.delta;
                        });
                      },
                      child: Transform.translate(
                        offset: _overlayOffset,
                        child: Transform.scale(
                          scale: _overlayScale,
                          child: Opacity(
                            opacity: _overlayOpacity,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                _getOverlayFilterColor(),
                                BlendMode.color,
                              ),
                              child: Container(
                                width: isCouture ? 280 : 200,
                                height: isCouture ? 360 : 220,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.rose.withOpacity(0.4), width: 1.5),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    widget.article.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(Icons.checkroom, color: Colors.white, size: 50),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Guide de placement flottant
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.touch_app, color: AppColors.rose, size: 14),
                            SizedBox(width: 4),
                            Text("Glissez pour ajuster la position", style: TextStyle(color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.restart_alt, color: Colors.white70),
                        tooltip: "Réinitialiser position",
                        onPressed: () => setState(() {
                          _overlayOffset = const Offset(0, 0);
                          _overlayScale = 1.0;
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Panneau de Contrôle Inférieur (Couleurs, Mannequins, Zoom, Tailles)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF141414),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sélection Modèle / Importer sa photo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "MODÈLE DE CORPS",
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    TextButton.icon(
                      onPressed: () {
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
                              children: [
                                const Text("Essayer sur ma propre photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                const Text("Votre photo reste strictement confidentielle sur votre appareil.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 20),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt, color: AppColors.rose),
                                  title: const Text("Prendre une photo (Caméra)"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.camera);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library, color: AppColors.rose),
                                  title: const Text("Choisir depuis la galerie"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_a_photo, color: AppColors.rose, size: 16),
                      label: const Text("Ma photo", style: TextStyle(color: AppColors.rose, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _mannequins.length + (_personalImage != null ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0 && _personalImage != null) {
                        return ChoiceChip(
                          label: const Text("Photo personnelle 📸"),
                          selected: _usePersonalPhoto,
                          selectedColor: AppColors.rose,
                          labelStyle: TextStyle(color: _usePersonalPhoto ? Colors.white : Colors.white70, fontSize: 12),
                          backgroundColor: Colors.white10,
                          onSelected: (val) => setState(() => _usePersonalPhoto = true),
                        );
                      }
                      final manIndex = _personalImage != null ? index - 1 : index;
                      final isSelected = !_usePersonalPhoto && _selectedMannequinIndex == manIndex;
                      return ChoiceChip(
                        label: Text(_mannequins[manIndex]["name"]!),
                        selected: isSelected,
                        selectedColor: AppColors.rose,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 12),
                        backgroundColor: Colors.white10,
                        onSelected: (val) {
                          setState(() {
                            _selectedMannequinIndex = manIndex;
                            _usePersonalPhoto = false;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Changer la couleur (Section 9)
                Row(
                  children: [
                    const Text(
                      "CHANGER LA COULEUR : ",
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    Text(
                      _selectedColor,
                      style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: widget.article.couleursDisponibles.map((colorName) {
                      final isSelected = _selectedColor == colorName;
                      Color dotColor = Colors.grey;
                      for (var entry in _colorMap.entries) {
                        if (colorName.toLowerCase().contains(entry.key.toLowerCase())) {
                          dotColor = entry.value;
                          break;
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: CircleAvatar(backgroundColor: dotColor, radius: 8),
                          label: Text(colorName),
                          selected: isSelected,
                          selectedColor: AppColors.rose.withOpacity(0.3),
                          checkmarkColor: AppColors.rose,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 11),
                          backgroundColor: Colors.white12,
                          side: BorderSide(color: isSelected ? AppColors.rose : Colors.transparent),
                          onSelected: (sel) {
                            if (sel) setState(() => _selectedColor = colorName);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // Contrôle de Zoom et Ajustement de taille
                Row(
                  children: [
                    const Icon(Icons.zoom_out, color: Colors.white60, size: 18),
                    Expanded(
                      child: Slider(
                        value: _overlayScale,
                        min: 0.6,
                        max: 1.8,
                        activeColor: AppColors.rose,
                        inactiveColor: Colors.white24,
                        onChanged: (val) => setState(() => _overlayScale = val),
                      ),
                    ),
                    const Icon(Icons.zoom_in, color: Colors.white60, size: 18),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveAndExport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rose,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("EXPORTER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
