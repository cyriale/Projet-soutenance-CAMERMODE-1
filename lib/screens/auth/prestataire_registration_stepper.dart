
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_colors.dart';
import '../../compronents/app_button.dart';
import '../../compronents/app_text_field.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/verification_service.dart';
import 'package:flutter/foundation.dart';

class PrestataireRegistrationStepper extends StatefulWidget {
  const PrestataireRegistrationStepper({super.key});

  @override
  State<PrestataireRegistrationStepper> createState() => _PrestataireRegistrationStepperState();
}

class _PrestataireRegistrationStepperState extends State<PrestataireRegistrationStepper> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isUpgrade = false;
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _verificationService = VerificationService();
  final _picker = ImagePicker();

  // Data
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _idNumberController = TextEditingController();
  
  String _businessType = 'Couture';
  String _idType = 'CNI';
  bool _isWorkingAtHome = false;
  
  XFile? _profileImage;
  XFile? _idImage;
  XFile? _proProofImage;
  XFile? _shopImage;
  XFile? _selfieImage;

  // Cache pour l'affichage des images sans dart:io
  final Map<String, Uint8List> _imageBytes = {};

  @override
  void initState() {
    super.initState();
    if (_authService.currentUser != null) {
      _isUpgrade = true;
      _nomController.text = "Utilisateur"; 
      _prenomController.text = "Client";
      _emailController.text = _authService.currentUser!.email ?? "";
    }
  }

  Future<void> _pickImage(String type) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Source pour : $type", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.rose),
              title: const Text("Prendre une photo"),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                if (picked != null) _setImage(type, picked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.rose),
              title: const Text("Choisir depuis la galerie"),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                if (picked != null) _setImage(type, picked);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setImage(String type, XFile file) async {
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes[type] = bytes;
      if (type == 'profile') _profileImage = file;
      if (type == 'id') _idImage = file;
      if (type == 'pro') _proProofImage = file;
      if (type == 'shop') _shopImage = file;
      if (type == 'selfie') _selfieImage = file;
    });
  }

  bool _validateCurrentStep() {
    if (!_formKey.currentState!.validate()) return false;

    if (_currentStep == 0) {
      if (!_isUpgrade && _passwordController.text.length < 8) {
        _showError("Le mot de passe doit faire au moins 8 caractères.");
        return false;
      }
      if (_phoneController.text.isEmpty) {
        _showError("Le numéro de téléphone est obligatoire pour un prestataire.");
        return false;
      }
    }

    if (_currentStep == 2) {
      if (_idImage == null) {
        _showError("Veuillez fournir votre pièce d'identité.");
        return false;
      }
    }

    if (_currentStep == 3) {
      if (_proProofImage == null) {
        _showError("Veuillez fournir un justificatif professionnel.");
        return false;
      }
      if (!_isWorkingAtHome && _shopImage == null) {
        _showError("La photo de la boutique est obligatoire.");
        return false;
      }
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.erreur, behavior: SnackBarBehavior.floating),
    );
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 4) {
        setState(() => _currentStep++);
      } else {
        _submit();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      String? userId;
      
      if (!_isUpgrade) {
        final error = await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          role: UserRole.prestataire,
        );
        if (error != null) throw error;
        userId = _authService.currentUser?.uid;
      } else {
        userId = _authService.currentUser?.uid;
      }

      if (userId == null) throw "Utilisateur introuvable";

      Map<String, dynamic> verificationData = {
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'telephone': _phoneController.text.trim(),
        'dateNaissance': _dobController.text.trim(),
        'businessName': _businessNameController.text.trim(),
        'businessType': _businessType,
        'adresseActivite': _addressController.text.trim(),
        'idDocumentType': _idType,
        'idDocumentNumber': _idNumberController.text.trim(),
        'isWorkingAtHome': _isWorkingAtHome,
        'verificationStatus': 'enAttente',
        'role': 'prestataire',
      };

      if (_profileImage != null) {
        verificationData['photoUrl'] = await _verificationService.uploadDocument(userId: userId, file: _profileImage!, folderName: 'profile');
      }
      
      verificationData['idDocumentUrl'] = await _verificationService.uploadDocument(userId: userId, file: _idImage!, folderName: 'identity');
      verificationData['professionalProofUrl'] = await _verificationService.uploadDocument(userId: userId, file: _proProofImage!, folderName: 'professional');
      
      if (!_isWorkingAtHome && _shopImage != null) {
        verificationData['shopProofUrl'] = await _verificationService.uploadDocument(userId: userId, file: _shopImage!, folderName: 'shop');
      }
      if (_selfieImage != null) {
        verificationData['selfieUrl'] = await _verificationService.uploadDocument(userId: userId, file: _selfieImage!, folderName: 'security');
      }

      await _verificationService.submitVerification(userId: userId, verificationData: verificationData);

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dossier soumis avec succès !"), backgroundColor: AppColors.succes));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(title: const Text("Vérification Prestataire"), backgroundColor: Colors.white, elevation: 0),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.rose))
        : Form(
            key: _formKey,
            child: Column(
              children: [
                _buildProgressBar(),
                Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: _buildCurrentStep())),
                _buildBottomButtons(),
              ],
            ),
          ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          bool isActive = index <= _currentStep;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            width: 40,
            decoration: BoxDecoration(color: isActive ? AppColors.rose : AppColors.ligne, borderRadius: BorderRadius.circular(3)),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _stepPersonalInfo();
      case 1: return _stepActivity();
      case 2: return _stepIdentity();
      case 3: return _stepProfessional();
      case 4: return _stepFinal();
      default: return const SizedBox();
    }
  }

  Widget _stepPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Vérification de l'identité", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Confirmez vos informations personnelles avant de continuer.", style: TextStyle(color: AppColors.texteSecondaire)),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickImage('profile'),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: _imageBytes['profile'] != null 
                    ? MemoryImage(_imageBytes['profile']!) 
                    : null,
                  child: _imageBytes['profile'] == null ? const Icon(Icons.add_a_photo, size: 40, color: AppColors.rose) : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text("Photo de profil"),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppTextField(controller: _nomController, labelText: "Nom", validator: (v) => v!.isEmpty ? "Requis" : null),
        const SizedBox(height: 16),
        AppTextField(controller: _prenomController, labelText: "Prénom", validator: (v) => v!.isEmpty ? "Requis" : null),
        const SizedBox(height: 16),
        AppTextField(
          controller: _dobController, 
          labelText: "Date de naissance", 
          prefixIcon: const Icon(Icons.calendar_today, size: 18),
          hintText: "JJ/MM/AAAA",
          validator: (v) => v!.isEmpty ? "Requis" : null
        ),
        const SizedBox(height: 16),
        AppTextField(controller: _phoneController, labelText: "Numéro de téléphone", keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? "Requis" : null),
        if (!_isUpgrade) ...[
          const SizedBox(height: 16),
          AppTextField(controller: _emailController, labelText: "E-mail", keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? "Requis" : null),
          const SizedBox(height: 16),
          AppTextField(controller: _passwordController, labelText: "Mot de passe", obscureText: true, validator: (v) => v!.length < 8 ? "8 caractères min" : null),
        ],
      ],
    );
  }

  Widget _stepActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Votre Activité Pro", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        AppTextField(controller: _businessNameController, labelText: "Nom de la marque / Boutique", validator: (v) => v!.isEmpty ? "Requis" : null),
        const SizedBox(height: 24),
        const Text("Type d'activité", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _choiceChip("Couture"),
            const SizedBox(width: 12),
            _choiceChip("Coiffure"),
          ],
        ),
        const SizedBox(height: 24),
        AppTextField(controller: _addressController, labelText: "Adresse ou Zone d'activité", validator: (v) => v!.isEmpty ? "Requis" : null),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _isWorkingAtHome,
          onChanged: (v) => setState(() => _isWorkingAtHome = v!),
          title: const Text("Je travaille à domicile / Pas de boutique physique"),
          activeColor: AppColors.rose,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _stepIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pièce d'identité", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Une photo lisible de votre document officiel.", style: TextStyle(color: AppColors.texteSecondaire)),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: _idType,
          items: ['CNI', 'Passeport', 'Permis'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _idType = v!),
          decoration: const InputDecoration(labelText: "Type de pièce", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        AppTextField(controller: _idNumberController, labelText: "Numéro de la pièce", validator: (v) => v!.isEmpty ? "Requis" : null),
        const SizedBox(height: 24),
        _buildImagePickerBox("Photo de la pièce d'identité", 'id', () => _pickImage('id')),
      ],
    );
  }

  Widget _stepProfessional() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Preuves Professionnelles", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Documents pour la catégorie $_businessType.", style: const TextStyle(color: AppColors.texteSecondaire)),
        const SizedBox(height: 24),
        _buildImagePickerBox("Diplôme ou Attestation de formation", 'pro', () => _pickImage('pro')),
        if (!_isWorkingAtHome) ...[
          const SizedBox(height: 24),
          _buildImagePickerBox("Photo de la boutique / atelier", 'shop', () => _pickImage('shop')),
        ],
        const SizedBox(height: 24),
        _buildImagePickerBox("Selfie de vérification", 'selfie', () => _pickImage('selfie'), subtitle: "Prenez une photo de votre visage"),
      ],
    );
  }

  Widget _stepFinal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: Icon(Icons.fact_check_outlined, size: 70, color: AppColors.rose)),
        const SizedBox(height: 16),
        const Center(child: Text("Récapitulatif", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        const Center(child: Text("Vérifiez votre dossier avant soumission.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.texteSecondaire))),
        const SizedBox(height: 32),
        
        _buildSectionHeader("IDENTITÉ"),
        _buildSummaryRow("Nom", "${_nomController.text} ${_prenomController.text}"),
        _buildSummaryRow("Date Naissance", _dobController.text),
        _buildSummaryRow("Téléphone", _phoneController.text),

        const SizedBox(height: 20),
        _buildSectionHeader("ACTIVITÉ PROFESSIONNELLE"),
        _buildSummaryRow("Marque", _businessNameController.text),
        _buildSummaryRow("Domaine", _businessType),
        _buildSummaryRow("Localisation", _addressController.text),
        _buildSummaryRow("Mode", _isWorkingAtHome ? "À domicile" : "En boutique"),

        const SizedBox(height: 20),
        _buildSectionHeader("DOCUMENTS FOURNIS"),
        _buildSummaryRow("N° Pièce d'identité", _idNumberController.text),
        _buildSummaryRow("Justificatif Pro", _imageBytes['pro'] != null ? "✅ Reçu" : "❌ Manquant", isError: _imageBytes['pro'] == null),
        if (!_isWorkingAtHome)
          _buildSummaryRow("Photo Boutique", _imageBytes['shop'] != null ? "✅ Reçu" : "❌ Manquant", isError: _imageBytes['shop'] == null),
        _buildSummaryRow("Selfie Sécurité", _imageBytes['selfie'] != null ? "✅ Pris" : "❌ Manquant", isError: _imageBytes['selfie'] == null),

        const SizedBox(height: 32),
        const Center(child: Text("Vos données sont protégées et seront vérifiées par l'admin.", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.texteSecondaire), textAlign: TextAlign.center)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(color: const Color(0x0D1C1C1C), borderRadius: BorderRadius.circular(4)),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.noir, letterSpacing: 1)),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 14)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isError ? AppColors.erreur : AppColors.noir))),
        ],
      ),
    );
  }

  Widget _buildImagePickerBox(String title, String type, VoidCallback onTap, {String? subtitle}) {
    final bytes = _imageBytes[type];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.ligne)),
            child: bytes != null 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12), 
                  child: Image.memory(bytes, fit: BoxFit.cover), 
                )
              : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, size: 40, color: AppColors.rose), SizedBox(height: 8), Text("Cliquer pour ajouter")]),
          ),
        ),
      ],
    );
  }

  Widget _choiceChip(String label) {
    bool isSelected = _businessType == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (v) => setState(() => _businessType = label),
      selectedColor: AppColors.rose,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.noir),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _prevStep,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56), side: const BorderSide(color: AppColors.rose), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("RETOUR", style: TextStyle(color: AppColors.rose)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: AppButton(text: _currentStep == 4 ? "SOUMETTRE MON DOSSIER" : "SUIVANT", onPressed: _nextStep)),
        ],
      ),
    );
  }
}
