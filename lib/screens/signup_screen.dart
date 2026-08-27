
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../compronents/app_button.dart';
import '../compronents/app_text_field.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import '../services/verification_service.dart';
import '../models/user_model.dart';

class SignupScreen extends StatefulWidget {
  final UserRole selectedRole;
  const SignupScreen({super.key, required this.selectedRole});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  
  String _businessType = 'Couture';
  final AuthService _authService = AuthService();
  final VerificationService _verificationService = VerificationService();
  final _picker = ImagePicker();
  
  File? _profileImage;
  bool _isLoading = false;
  bool _acceptTerms = false;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Photo de profil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.rose),
              title: const Text("Prendre une photo"),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                if (picked != null) setState(() => _profileImage = File(picked.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.rose),
              title: const Text("Choisir depuis la galerie"),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                if (picked != null) setState(() => _profileImage = File(picked.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 8) return 'Minimum 8 caractères';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool isPrestataire = widget.selectedRole == UserRole.prestataire;

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPrestataire ? 'Inscription Prestataire' : 'Créer un compte Client',
                  style: const TextStyle(color: AppColors.noir, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  isPrestataire 
                    ? 'Proposez vos créations et gérez vos rendez-vous.' 
                    : 'Découvrez votre style personnalisé en quelques clics.',
                  style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 14),
                ),
                const SizedBox(height: 32),

                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null 
                            ? const Icon(Icons.add_a_photo, size: 40, color: AppColors.rose) 
                            : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Photo de profil",
                        style: TextStyle(color: AppColors.texteSecondaire, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                if (isPrestataire) ...[
                  AppTextField(
                    controller: _businessNameController,
                    labelText: 'Nom de votre marque',
                    prefixIcon: const Icon(Icons.storefront, color: AppColors.noir),
                    validator: (v) => v!.isEmpty ? 'Nom de marque requis' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text("Type d'activité :", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      _buildTypeChip('Couture'),
                      const SizedBox(width: 10),
                      _buildTypeChip('Coiffure'),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                Row(
                  children: [
                    Expanded(child: AppTextField(
                      controller: _nomController, 
                      labelText: 'Nom',
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: AppTextField(
                      controller: _prenomController, 
                      labelText: 'Prénom',
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    )),
                  ],
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _emailController,
                  labelText: 'Adresse e-mail',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.noir),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email invalide' : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _passwordController,
                  labelText: 'Mot de passe',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.noir),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 30),
                
                CheckboxListTile(
                  value: _acceptTerms,
                  onChanged: (v) => setState(() => _acceptTerms = v!),
                  title: const Text("J'accepte les conditions d'utilisation", style: TextStyle(fontSize: 12)),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.rose,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 30),
                AppButton(
                  text: 'S\u0027INSCRIRE',
                  isLoading: _isLoading,
                  onPressed: _acceptTerms && !_isLoading ? _handleSignUp : () {},
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        String? profileUrl;
        
        // 1. Create account first to get UID
        final error = await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          role: widget.selectedRole,
          businessName: _businessNameController.text.trim(),
          businessType: _businessType,
        );

        if (error != null) throw error;

        // 2. Upload photo if present
        final userId = _authService.currentUser?.uid;
        if (userId != null && _profileImage != null) {
          profileUrl = await _verificationService.uploadDocument(
            userId: userId, 
            file: _profileImage!, 
            folderName: 'profile'
          );
          
          // Update user record with photoUrl
          await _authService.updateUserProfile(userId, {'photoUrl': profileUrl});
        }

        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.erreur),
          );
        }
      }
    }
  }

  Widget _buildTypeChip(String label) {
    bool isSelected = _businessType == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _businessType = label),
      selectedColor: AppColors.rose,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.noir),
    );
  }
}
