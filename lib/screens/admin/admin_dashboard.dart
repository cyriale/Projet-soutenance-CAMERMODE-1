
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/verification_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final verificationService = VerificationService();

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Admin : Vérifications"),
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: verificationService.getPendingVerifications(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final verifications = snapshot.data!;
          
          if (verifications.isEmpty) {
            return const Center(child: Text("Aucune demande en attente."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: verifications.length,
            itemBuilder: (context, index) {
              final user = verifications[index];
              return Card(
                child: ListTile(
                  title: Text("${user.nom} ${user.prenom}"),
                  subtitle: Text("${user.businessName} (${user.businessType})"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showReviewDialog(context, user),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showReviewDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Vérifier ${user.businessName}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ID Number: ${user.idDocumentNumber}"),
              if (user.idDocumentUrl != null) Image.network(user.idDocumentUrl!, height: 100),
              const SizedBox(height: 10),
              const Text("Justificatif Pro:"),
              if (user.professionalProofUrl != null) Image.network(user.professionalProofUrl!, height: 100),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => _update(context, user.uid, VerificationStatus.refuse), child: const Text("Refuser", style: TextStyle(color: Colors.red))),
          TextButton(onPressed: () => _update(context, user.uid, VerificationStatus.verifie), child: const Text("Valider", style: TextStyle(color: Colors.green))),
        ],
      ),
    );
  }

  void _update(BuildContext context, String uid, VerificationStatus status) async {
    await VerificationService().updateStatus(uid, status);
    if (context.mounted) Navigator.pop(context);
  }
}
