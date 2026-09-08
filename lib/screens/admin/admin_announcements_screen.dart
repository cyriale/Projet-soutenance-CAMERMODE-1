import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../views_models/administrateur/admin_view_model.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.roseClair,
          appBar: AppBar(
            title: const Text("Envoyer une Annonce"),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.noir, size: 20),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.noir.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.campaign, color: AppColors.rose, size: 28),
                          SizedBox(width: 12),
                          Text(
                            "Nouvelle Annonce",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Ce message sera visible par tous les utilisateurs de la plateforme.",
                        style: TextStyle(color: AppColors.texteSecondaire, fontSize: 14),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: "Titre de l'annonce",
                          hintText: "Ex: Maintenance prévue, Promotion...",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.title),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _contentController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: "Contenu du message",
                          hintText: "Écrivez votre message ici...",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading 
                            ? null 
                            : () async {
                              if (_titleController.text.trim().isNotEmpty && 
                                  _contentController.text.trim().isNotEmpty) {
                                
                                final messenger = ScaffoldMessenger.of(context);
                                await viewModel.sendAnnouncement(
                                  _titleController.text.trim(), 
                                  _contentController.text.trim()
                                );
                                
                                if (mounted) {
                                  _titleController.clear();
                                  _contentController.clear();
                                  
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text("🚀 Annonce diffusée avec succès !"),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Veuillez remplir tous les champs."),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.rose,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: viewModel.isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "DIFFUSER À TOUTE LA COMMUNAUTÉ", 
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
