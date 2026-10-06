import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../compronents/app_button.dart';
import '../../compronents/app_text_field.dart';
import '../../models/article_model.dart';
import '../../views_models/prestataire/add_article_view_model.dart';

class AddArticleScreen extends StatefulWidget {
  final ArticleModel? existingArticle;
  final XFile? initialImage;

  const AddArticleScreen({
    super.key,
    this.existingArticle,
    this.initialImage,
  });

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titreController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _prixController;
  late final TextEditingController _tagsController;
  late final TextEditingController _categorieController;
  
  late ArticleType _type;
  late bool _isPublished;
  Uint8List? _imageBytes;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    final art = widget.existingArticle;
    _titreController = TextEditingController(text: art?.titre ?? "");
    _descriptionController = TextEditingController(text: art?.description ?? "");
    _prixController = TextEditingController(text: art != null ? art.prix.toInt().toString() : "");
    _tagsController = TextEditingController(text: art != null ? art.tags.join(', ') : "");
    _categorieController = TextEditingController(text: art?.categorie ?? "Robes de Soirée");
    _type = art?.type ?? ArticleType.couture;
    _isPublished = art?.isPublished ?? true;

    if (widget.initialImage != null) {
      widget.initialImage!.readAsBytes().then((bytes) {
        if (mounted) setState(() => _imageBytes = bytes);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit && widget.initialImage != null) {
      _isInit = false;
      _viewModel.setImageFile(widget.initialImage!);
    }
  }

  final AddArticleViewModel _viewModel = AddArticleViewModel();

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _tagsController.dispose();
    _categorieController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingArticle != null;

    return ChangeNotifierProvider<AddArticleViewModel>.value(
      value: _viewModel,
      child: Consumer<AddArticleViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.roseClair,
            appBar: AppBar(
              title: Text(
                isEditing ? "Modifier l'article" : "Ajouter une Création",
                style: const TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.noir),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sélecteur d'image (Caméra / Galerie)
                    Center(
                      child: GestureDetector(
                        onTap: () => _showImageSourceActionSheet(context, viewModel),
                        child: Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.ligne, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _imageBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                                )
                              : (isEditing && widget.existingArticle!.imageUrl.isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            widget.existingArticle!.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Center(
                                              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 12,
                                            right: 12,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.edit, color: Colors.white, size: 14),
                                                  SizedBox(width: 4),
                                                  Text("Changer la photo", style: TextStyle(color: Colors.white, fontSize: 11)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.rose.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.add_a_photo, size: 40, color: AppColors.rose),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          "Ajouter la photo de l'article",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "Appareil photo (Filmer) ou Galerie (Exporter)",
                                          style: TextStyle(color: AppColors.texteSecondaire, fontSize: 12),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Type & Catégorie
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<ArticleType>(
                            value: _type,
                            decoration: InputDecoration(
                              labelText: "Type de création",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: const [
                              DropdownMenuItem(value: ArticleType.couture, child: Text("Couture / Vêtement")),
                              DropdownMenuItem(value: ArticleType.coiffure, child: Text("Coiffure / Tresses")),
                            ],
                            onChanged: (val) => setState(() => _type = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            controller: _categorieController,
                            labelText: "Catégorie",
                            hintText: "ex: Robes, Boubou, Nattes...",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _titreController,
                      labelText: "Titre de la création",
                      hintText: "ex: Robe Kaba Élégance Soirée",
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Le titre est requis" : null,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _descriptionController,
                      labelText: "Description détaillée",
                      hintText: "Matière, finitions, temps de confection, conseils d'entretien...",
                      maxLines: 4,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "La description est requise" : null,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _prixController,
                      labelText: "Prix (FCFA)",
                      hintText: "ex: 25000",
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Le prix est requis";
                        if (double.tryParse(v.trim()) == null) return "Prix invalide";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _tagsController,
                      labelText: "Tags (séparés par des virgules)",
                      hintText: "africain, chic, wax, mariage, soyeux",
                    ),
                    const SizedBox(height: 20),

                    // Option de publication
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.ligne),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.rose,
                        title: const Text("Publier dans le catalogue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          _isPublished
                              ? "L'article sera visible par tous les clients immédiatement."
                              : "L'article sera sauvegardé comme brouillon masqué.",
                          style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire),
                        ),
                        value: _isPublished,
                        onChanged: (val) => setState(() => _isPublished = val),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Bouton de validation
                    AppButton(
                      text: isEditing ? "ENREGISTRER LES MODIFICATIONS" : "PUBLIER LA CRÉATION",
                      isLoading: viewModel.isLoading,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        if (!isEditing && viewModel.imageFile == null && _imageBytes == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Veuillez sélectionner ou prendre une photo."),
                              backgroundColor: AppColors.erreur,
                            ),
                          );
                          return;
                        }

                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final tags = _tagsController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        final prix = double.parse(_prixController.text.trim());

                        bool success = false;
                        if (isEditing) {
                          success = await viewModel.updateArticle(
                            articleId: widget.existingArticle!.id,
                            titre: _titreController.text.trim(),
                            description: _descriptionController.text.trim(),
                            prix: prix,
                            type: _type,
                            categorie: _categorieController.text.trim(),
                            tags: tags,
                            isPublished: _isPublished,
                            currentImageUrl: widget.existingArticle!.imageUrl,
                          );
                        } else {
                          success = await viewModel.submitArticle(
                            titre: _titreController.text.trim(),
                            description: _descriptionController.text.trim(),
                            prix: prix,
                            type: _type,
                            categorie: _categorieController.text.trim(),
                            tags: tags,
                            isPublished: _isPublished,
                          );
                        }

                        if (!mounted) return;
                        if (success) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(isEditing ? "Article mis à jour avec succès !" : "Création publiée avec succès !"),
                              backgroundColor: AppColors.succes,
                            ),
                          );
                          navigator.pop(true);
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text("Une erreur est survenue lors de l'enregistrement."),
                              backgroundColor: AppColors.erreur,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context, AddArticleViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const Text("Choisir une photo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.rose.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: AppColors.rose),
                  ),
                  title: const Text('Prendre une photo (Appareil photo)'),
                  subtitle: const Text('Prenez directement un cliché de votre création'),
                  onTap: () async {
                    Navigator.pop(context);
                    await viewModel.pickImage(ImageSource.camera);
                    if (viewModel.imageFile != null) {
                      final bytes = await viewModel.imageFile!.readAsBytes();
                      setState(() => _imageBytes = bytes);
                    }
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.photo_library, color: Colors.blue),
                  ),
                  title: const Text('Importer depuis la galerie (Exporter)'),
                  subtitle: const Text('Choisissez une photo existante dans votre téléphone'),
                  onTap: () async {
                    Navigator.pop(context);
                    await viewModel.pickImage(ImageSource.gallery);
                    if (viewModel.imageFile != null) {
                      final bytes = await viewModel.imageFile!.readAsBytes();
                      setState(() => _imageBytes = bytes);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
