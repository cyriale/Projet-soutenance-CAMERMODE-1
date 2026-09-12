
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/user_model.dart';
import '../../views_models/common/edit_profile_view_model.dart';
import '../../compronents/app_button.dart';
import '../../compronents/app_text_field.dart';
import 'package:flutter/foundation.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _phoneController;
  late TextEditingController _businessController;

  Uint8List? _newImageBytes;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.user.nom);
    _prenomController = TextEditingController(text: widget.user.prenom);
    _phoneController = TextEditingController(text: widget.user.telephone ?? "");
    _businessController = TextEditingController(text: widget.user.businessName ?? "");
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileViewModel(),
      child: Consumer<EditProfileViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.roseClair,
            appBar: AppBar(
              title: const Text("Modifier le Profil"),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Photo de profil
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: _newImageBytes != null
                              ? MemoryImage(_newImageBytes!)
                              : (widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty
                                  ? NetworkImage(widget.user.photoUrl!)
                                  : null),
                          child: _newImageBytes == null && (widget.user.photoUrl == null || widget.user.photoUrl!.isEmpty)
                              ? Text(widget.user.nom[0].toUpperCase(), style: const TextStyle(fontSize: 40, color: AppColors.rose))
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: AppColors.rose,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                              onPressed: () async {
                                await viewModel.pickImage();
                                if (viewModel.newProfileImage != null) {
                                  final bytes = await viewModel.newProfileImage!.readAsBytes();
                                  setState(() => _newImageBytes = bytes);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  AppTextField(
                    controller: _prenomController,
                    labelText: "Prénom",
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _nomController,
                    labelText: "Nom",
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _phoneController,
                    labelText: "Numéro de téléphone",
                    keyboardType: TextInputType.phone,
                  ),
                  
                  if (widget.user.role == UserRole.prestataire) ...[
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _businessController,
                      labelText: "Nom de la marque / Boutique",
                    ),
                  ],

                  const SizedBox(height: 48),
                  AppButton(
                    text: "ENREGISTRER LES MODIFICATIONS",
                    isLoading: viewModel.isLoading,
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      final success = await viewModel.updateProfile(
                        user: widget.user,
                        nom: _nomController.text.trim(),
                        prenom: _prenomController.text.trim(),
                        telephone: _phoneController.text.trim(),
                        businessName: _businessController.text.trim(),
                      );

                      if (!mounted) return;
                      if (success) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text("Profil mis à jour !"), backgroundColor: AppColors.succes),
                        );
                        navigator.pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
