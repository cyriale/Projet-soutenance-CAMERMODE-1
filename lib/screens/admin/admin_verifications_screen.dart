
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/user_model.dart';
import '../../views_models/administrateur/admin_view_model.dart';

class AdminVerificationsScreen extends StatelessWidget {
  const AdminVerificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Dossiers en attente de vérification"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.noir, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: viewModel.pendingPrestataires.isEmpty
          ? const Center(child: Text("Aucun dossier en attente de vérification."))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: viewModel.pendingPrestataires.length,
              itemBuilder: (context, index) {
                final user = viewModel.pendingPrestataires[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.businessName ?? "Marque sans nom", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.rose)),
                                Text("Proposé par ${user.nom} ${user.prenom}", style: const TextStyle(color: AppColors.texteSecondaire)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                              child: Text(user.businessType ?? "N/A", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),
                        const Text("DOCUMENTS JUSTIFICATIFS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildDocThumbnail(context, "Pièce d'identité", user.idDocumentUrl, user.idDocumentNumber),
                            _buildDocThumbnail(context, "Justificatif Pro", user.professionalProofUrl),
                            if (!user.isWorkingAtHome) _buildDocThumbnail(context, "Boutique / Atelier", user.shopProofUrl),
                            _buildDocThumbnail(context, "Selfie Sécurité", user.selfieUrl),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Bouton REJET DEFINITIF
                            TextButton(
                              onPressed: () => _showDecisionDialog(context, viewModel, user.uid, VerificationStatus.refuse),
                              child: const Text("REFUSER DÉFINITIVEMENT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            // Bouton CORRECTION
                            OutlinedButton(
                              onPressed: () => _showDecisionDialog(context, viewModel, user.uid, VerificationStatus.documentsACorriger),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange)),
                              child: const Text("DEMANDER CORRECTION"),
                            ),
                            const SizedBox(width: 12),
                            // Bouton VALIDATION
                            ElevatedButton(
                              onPressed: () => viewModel.verifyPrestataire(user.uid, VerificationStatus.verifie),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                              child: const Text("VALIDER LE PRESTATAIRE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDocThumbnail(BuildContext context, String label, String? url, [String? extra]) {
    if (url == null) return const SizedBox();
    return InkWell(
      onTap: () => _showFullScreenImage(context, url, label),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ligne),
              image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          if (extra != null) Text(extra, style: const TextStyle(fontSize: 10, color: AppColors.texteSecondaire)),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(url, fit: BoxFit.contain),
            Positioned(top: 20, left: 20, child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
            Positioned(right: 20, top: 20, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context))),
          ],
        ),
      ),
    );
  }

  void _showDecisionDialog(BuildContext context, AdminViewModel vm, String uid, VerificationStatus status) {
    final controller = TextEditingController();
    final isDefinitive = status == VerificationStatus.refuse;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isDefinitive ? "Refuser définitivement ?" : "Demander une correction"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isDefinitive 
              ? "Le prestataire sera notifié de son refus définitif d'accès à la plateforme." 
              : "Le prestataire devra modifier son dossier selon vos instructions."),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Raison / Motif (obligatoire)", border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              vm.verifyPrestataire(uid, status, reason: controller.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: isDefinitive ? Colors.red : Colors.orange),
            child: Text(isDefinitive ? "CONFIRMER LE REFUS" : "ENVOYER AU PRESTATAIRE", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
