import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../models/user_model.dart';
import '../../compronents/app_text_field.dart';
import '../../compronents/app_button.dart';

class PrestataireBusinessInfoScreen extends StatefulWidget {
  final UserModel user;

  const PrestataireBusinessInfoScreen({super.key, required this.user});

  @override
  State<PrestataireBusinessInfoScreen> createState() => _PrestataireBusinessInfoScreenState();
}

class _PrestataireBusinessInfoScreenState extends State<PrestataireBusinessInfoScreen> {
  late TextEditingController _businessNameController;
  late TextEditingController _businessTypeController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  bool _isLoading = false;

  final List<String> _categories = [
    "Atelier de Couture & Stylisme",
    "Salon de Coiffure & Beauté",
    "Créateur de Mode & Accessoires",
    "Maquillage & Esthétique",
    "Tisserand / Artisan Textile",
  ];

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController(text: widget.user.businessName ?? "");
    _businessTypeController = TextEditingController(text: widget.user.businessType ?? "Atelier de Couture & Stylisme");
    _addressController = TextEditingController(text: widget.user.adresseActivite ?? "");
    _phoneController = TextEditingController(text: widget.user.telephone ?? "");
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveInfo() async {
    final businessName = _businessNameController.text.trim();
    if (businessName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le nom de l'atelier/marque est obligatoire.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({
        'businessName': businessName,
        'businessType': _businessTypeController.text.trim(),
        'adresseActivite': _addressController.text.trim(),
        'telephone': _phoneController.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Informations professionnelles mises à jour avec succès !"),
            backgroundColor: AppColors.succes,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: AppColors.erreur),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text(
          "Informations Professionnelles",
          style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.noir),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: AppColors.rose, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.isVerifiedUser ? "Profil Professionnel Vérifié ✅" : "Profil Professionnel Enregistré",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Ces informations sont affichées sur vos articles et votre fiche vitrine publique.",
                          style: TextStyle(fontSize: 12, color: AppColors.texteSecondaire),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Nom de l'établissement / Marque",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.noir),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _businessNameController,
              labelText: "Ex: Atelier Douala Couture",
              prefixIcon: const Icon(Icons.storefront, color: AppColors.rose),
            ),
            const SizedBox(height: 18),

            const Text(
              "Catégorie d'activité",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.noir),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.ligne),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _categories.contains(_businessTypeController.text)
                      ? _businessTypeController.text
                      : _categories.first,
                  items: _categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _businessTypeController.text = val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              "Adresse de l'atelier / salon",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.noir),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _addressController,
              labelText: "Ex: Akwa, Rue de la Joie, Douala",
              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.rose),
            ),
            const SizedBox(height: 18),

            const Text(
              "Numéro de contact professionnel",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.noir),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _phoneController,
              labelText: "Ex: +237 6XX XX XX XX",
              prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.rose),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 18),

            const Text(
              "Présentation / Biographie",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.noir),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Décrivez votre savoir-faire, vos spécialités de tissus (Wax, Kaba, Bamiléké) ou coiffures...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.ligne),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.ligne),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.rose, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),

            AppButton(
              text: "ENREGISTRER LES MODIFICATIONS",
              isLoading: _isLoading,
              onPressed: _saveInfo,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
