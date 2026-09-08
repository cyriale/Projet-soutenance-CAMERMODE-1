
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../compronents/app_button.dart';
import '../../compronents/app_text_field.dart';
import '../../models/article_model.dart';
import '../../views_models/prestataire/add_article_view_model.dart';
import 'package:flutter/foundation.dart';

class AddArticleScreen extends StatefulWidget {
  const AddArticleScreen({super.key});

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  final _tagsController = TextEditingController();
  
  ArticleType _type = ArticleType.couture;
  String _categorie = "Robes de Soirée";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddArticleViewModel(),
      child: Consumer<AddArticleViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.roseClair,
            appBar: AppBar(
              title: const Text("Ajouter une Création"),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sélecteur d'image
                    Center(
                      child: GestureDetector(
                        onTap: () => _showImageSourceActionSheet(context, viewModel),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.ligne),
                          ),
                          child: viewModel.imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: kIsWeb 
                                    ? Image.network(viewModel.imageFile!.path, fit: BoxFit.cover)
                                    : Image.file(File(viewModel.imageFile!.path), fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 50, color: AppColors.rose),
                                    SizedBox(height: 8),
                                    Text("Ajouter une photo"),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Type & Catégorie
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<ArticleType>(
                            value: _type,
                            decoration: const InputDecoration(labelText: "Type"),
                            items: const [
                              DropdownMenuItem(value: ArticleType.couture, child: Text("Couture")),
                              DropdownMenuItem(value: ArticleType.coiffure, child: Text("Coiffure")),
                            ],
                            onChanged: (val) => setState(() => _type = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            controller: TextEditingController(text: _categorie),
                            labelText: "Catégorie",
                            onChanged: (v) => _categorie = v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    AppTextField(
                      controller: _titreController,
                      labelText: "Titre de la création",
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _descriptionController,
                      labelText: "Description détaillée",
                      maxLines: 4,
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _prixController,
                      labelText: "Prix (FCFA)",
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _tagsController,
                      labelText: "Tags (séparés par des virgules)",
                      hintText: "sirène, chic, mariage...",
                    ),
                    const SizedBox(height: 40),

                    AppButton(
                      text: "PUBLIER LA CRÉATION",
                      isLoading: viewModel.isLoading,
                      onPressed: () async {
                        if (_formKey.currentState!.validate() && viewModel.imageFile != null) {
                          final tags = _tagsController.text.split(',').map((e) => e.trim()).toList();
                          final success = await viewModel.submitArticle(
                            titre: _titreController.text,
                            description: _descriptionController.text,
                            prix: double.parse(_prixController.text),
                            type: _type,
                            categorie: _categorie,
                            tags: tags,
                          );

                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Création publiée !"), backgroundColor: Colors.green),
                            );
                            Navigator.pop(context);
                          }
                        } else if (viewModel.imageFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Veuillez ajouter une photo.")),
                          );
                        }
                      },
                    ),
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
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Appareil photo'),
              onTap: () {
                Navigator.pop(context);
                viewModel.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                viewModel.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
