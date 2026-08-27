
import 'package:flutter/material.dart';
import '../compronents/app_button.dart';
import '../compronents/app_text_field.dart';
import '../core/app_colors.dart';
import '../models/article_model.dart';

class CompleteProfileScreen extends StatefulWidget {
  final ArticleType type;
  const CompleteProfileScreen({super.key, required this.type});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _poitrineController = TextEditingController();
  final TextEditingController _tailleController = TextEditingController();
  
  // ignore: unused_field
  String? _selectedHairType;
  final List<String> _hairTypes = ['Crépus (4C)', 'Frisés (3C)', 'Bouclés', 'Lisses'];

  @override
  Widget build(BuildContext context) {
    bool isCouture = widget.type == ArticleType.couture;

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: Text(isCouture ? "Mesures Couture" : "Profil Coiffure", style: const TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.noir, size: 20),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                isCouture ? Icons.straighten : Icons.face_retouching_natural,
                size: 80,
                color: AppColors.rose,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isCouture 
                ? "Prenez vos mesures pour un ajustement parfait." 
                : "Analysez votre visage pour voir cette coiffure sur vous.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.noir),
            ),
            const SizedBox(height: 30),
            
            if (isCouture) ...[
              AppTextField(controller: _poitrineController, labelText: "Tour de poitrine (cm)", keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              AppTextField(controller: _tailleController, labelText: "Tour de taille (cm)", keyboardType: TextInputType.number),
              const SizedBox(height: 30),
              AppButton(text: "LANCER LE SCAN CORPOREL", onPressed: () {}, backgroundColor: AppColors.noir),
            ] else ...[
              const Text("Votre type de cheveux", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.noir)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.ligne)),
                ),
                items: _hairTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedHairType = v),
                hint: const Text("Sélectionnez votre type"),
              ),
              const SizedBox(height: 30),
              AppButton(text: "SCANNER MON VISAGE (AR)", onPressed: () {}, backgroundColor: AppColors.noir),
            ],
            
            const SizedBox(height: 40),
            AppButton(
              text: "ENREGISTRER ET ESSAYER",
              onPressed: () => Navigator.pop(context, true), // Retourne 'true' pour dire que c'est enregistré
            ),
          ],
        ),
      ),
    );
  }
}
