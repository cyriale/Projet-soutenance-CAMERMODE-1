
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/article_model.dart';
import '../../services/article_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../views_models/administrateur/admin_view_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _searchQuery = "";
  String _roleFilter = "Tous";

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminViewModel>();
    
    final filteredUsers = viewModel.allUsers.where((u) {
      final name = "${u.nom} ${u.prenom}".toLowerCase();
      final email = u.email.toLowerCase();
      final matchesSearch = name.contains(_searchQuery.toLowerCase()) || email.contains(_searchQuery.toLowerCase());
      
      bool matchesRole = true;
      if (_roleFilter == "Clients") matchesRole = u.role == UserRole.client;
      if (_roleFilter == "Prestataires") matchesRole = u.role == UserRole.prestataire;
      if (_roleFilter == "Admins") matchesRole = u.role == UserRole.admin;

      return matchesSearch && matchesRole;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Annuaire des Utilisateurs"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.noir, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          _buildFilterDropdown(),
          const SizedBox(width: 16),
          _buildSearchField(),
          const SizedBox(width: 24),
        ],
      ),
      body: filteredUsers.isEmpty 
        ? const Center(child: Text("Aucun utilisateur trouvé."))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return _buildUserCard(context, viewModel, user);
            },
          ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButton<String>(
        value: _roleFilter,
        underline: const SizedBox(),
        items: ["Tous", "Clients", "Prestataires", "Admins"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) => setState(() => _roleFilter = val!),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 300,
        child: TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: "Rechercher par nom ou email...",
            prefixIcon: const Icon(Icons.search, color: AppColors.rose),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AdminViewModel viewModel, UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _showUserInspector(context, viewModel, user),
        leading: CircleAvatar(
          backgroundColor: AppColors.rose,
          backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null || user.photoUrl!.isEmpty ? Text(user.nom[0], style: const TextStyle(color: Colors.white)) : null,
        ),
        title: Text("${user.nom} ${user.prenom}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${user.email} • ${user.roleLabel}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.isBlocked) const Chip(label: Text("BLOQUÉ", style: TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.red),
            IconButton(
              icon: Icon(user.isBlocked ? Icons.lock : Icons.lock_open, color: user.isBlocked ? Colors.red : Colors.green),
              onPressed: () => viewModel.toggleBlockUser(user.uid, !user.isBlocked),
            ),
            IconButton(
              icon: const Icon(Icons.manage_search, color: AppColors.rose),
              tooltip: "Inspecter tout le contenu",
              onPressed: () => _showUserInspector(context, viewModel, user),
            ),
          ],
        ),
      ),
    );
  }

  // --- INSPECTEUR COMPLET DE L'UTILISATEUR (La fonctionnalité "Tout Voir") ---
  void _showUserInspector(BuildContext context, AdminViewModel viewModel, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("DOSSIER COMPLET : ${user.prenom} ${user.nom}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.noir)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(height: 40),
              Expanded(
                child: ListView(
                  children: [
                    _inspectorSection("📍 LOCALISATION ET COORDONNÉES", [
                      _inspectorRow(Icons.business, "Nom Commercial", user.businessName ?? "N/A"),
                      _inspectorRow(Icons.category, "Spécialité", user.businessType ?? "N/A"),
                      _inspectorRow(Icons.email, "Email", user.email),
                      _inspectorRow(Icons.phone, "Téléphone", user.telephone ?? "Non renseigné"),
                      _inspectorRow(Icons.cake, "Date Naissance", user.dateNaissance != null ? "${user.dateNaissance!.day}/${user.dateNaissance!.month}/${user.dateNaissance!.year}" : "N/A"),
                      _inspectorRow(Icons.location_on, "Adresse déclarée", user.adresseActivite ?? "Non renseignée"),
                      if (user.latitude != null && user.longitude != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 32, bottom: 12),
                          child: OutlinedButton.icon(
                            onPressed: () => _showLocationOnMap(context, user),
                            icon: const Icon(Icons.map_outlined, size: 16),
                            label: const Text("Vérifier sur Google Maps", style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue)),
                          ),
                        ),
                      _inspectorRow(Icons.home_work, "Type de structure", user.isWorkingAtHome ? "À domicile" : "Boutique physique"),
                      _inspectorRow(Icons.badge, "Document (${user.idDocumentType})", user.idDocumentNumber ?? "N/A"),
                      _inspectorRow(Icons.calendar_today, "Inscription", "${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}"),
                      _inspectorRow(Icons.verified_user, "Statut Vérification", user.verificationStatus?.toString().split('.').last ?? "Inconnu"),
                    ]),
                    
                    const SizedBox(height: 32),
                    
                    _inspectorSection("📑 DOCUMENTS DE VÉRIFICATION", [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _mediaPreview(context, "Photo Profil", user.photoUrl),
                          _mediaPreview(context, "Pièce d'identité", user.idDocumentUrl),
                          _mediaPreview(context, "Diplôme / Preuve Pro", user.professionalProofUrl),
                          if (!user.isWorkingAtHome) _mediaPreview(context, "Photo Boutique", user.shopProofUrl),
                          _mediaPreview(context, "Selfie Sécurité", user.selfieUrl),
                        ],
                      ),
                    ]),

                    if (user.role == UserRole.prestataire) ...[
                      const SizedBox(height: 24),
                      _inspectorSection("⚡ ACTIONS ADMINISTRATEUR SUR CE DOSSIER", [
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                viewModel.verifyPrestataire(user.uid, VerificationStatus.verifie);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Dossier prestataire validé avec succès !"), backgroundColor: Colors.green),
                                );
                              },
                              icon: const Icon(Icons.check, color: Colors.white, size: 18),
                              label: const Text("VALIDER LE PRESTATAIRE", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showCorrectionDialog(context, viewModel, user.uid);
                              },
                              icon: const Icon(Icons.edit_note, size: 18),
                              label: const Text("DEMANDER CORRECTION"),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.orange.shade800, side: BorderSide(color: Colors.orange.shade800)),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showRefusalDialog(context, viewModel, user.uid);
                              },
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text("REFUSER CE DOSSIER"),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                            ),
                          ],
                        ),
                      ]),
                      const SizedBox(height: 32),
                      const Text("🎨 CRÉATIONS ET ARTICLES PUBLIÉS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.rose, letterSpacing: 1.1)),
                      const SizedBox(height: 16),
                      StreamBuilder<List<ArticleModel>>(
                        stream: ArticleService().getPrestataireArticles(user.uid),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          final articles = snapshot.data!;
                          if (articles.isEmpty) return const Text("Aucun article publié par ce prestataire.");
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1),
                            itemCount: articles.length,
                            itemBuilder: (context, i) => _mediaPreview(context, articles[i].titre, articles[i].imageUrl),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inspectorSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.rose, letterSpacing: 1.1)),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _inspectorRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.texteSecondaire),
          const SizedBox(width: 12),
          Text("$label : ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _mediaPreview(BuildContext context, String label, String? url) {
    if (url == null || url.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _showFullScreenImage(context, url, label),
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ligne),
              image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(width: 150, child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(url, fit: BoxFit.contain, width: double.infinity, height: double.infinity),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationOnMap(BuildContext context, UserModel user) {
    if (user.latitude == null || user.longitude == null) return;
    final position = LatLng(user.latitude!, user.longitude!);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 600,
            height: 500,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: position, zoom: 15),
                  markers: {Marker(markerId: const MarkerId("pos"), position: position)},
                ),
                Positioned(top: 20, right: 20, child: CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCorrectionDialog(BuildContext context, AdminViewModel vm, String uid) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Demander une correction"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Indiquez au prestataire ce qu'il doit rectifier dans son dossier :"),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Ex: Photo CNI floue, merci de renouveler...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                vm.verifyPrestataire(uid, VerificationStatus.documentsACorriger, reason: controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Demande de correction transmise au prestataire."), backgroundColor: Colors.orange),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
            child: const Text("Envoyer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRefusalDialog(BuildContext context, AdminViewModel vm, String uid) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Refuser le dossier"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Indiquez la raison du refus :"),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Ex: Pièce d'identité non conforme...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                vm.verifyPrestataire(uid, VerificationStatus.refuse, reason: controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Refus enregistré."), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Confirmer le refus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
