
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/user_model.dart';
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
    
    // Filtrage dynamique
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
        title: const Text("Gestion des Utilisateurs"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.noir, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          // Filtre par rôle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DropdownButton<String>(
                value: _roleFilter,
                underline: const SizedBox(),
                items: ["Tous", "Clients", "Prestataires", "Admins"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) => setState(() => _roleFilter = val!),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 300,
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Rechercher un nom ou email...",
                  prefixIcon: const Icon(Icons.search, color: AppColors.rose),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: filteredUsers.isEmpty 
        ? const Center(child: Text("Aucun utilisateur trouvé."))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  onTap: () => _showUserDetails(context, user),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.rose,
                    backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                    child: user.photoUrl == null ? Text(user.nom[0], style: const TextStyle(color: Colors.white)) : null,
                  ),
                  title: Text("${user.nom} ${user.prenom}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${user.email} • ${user.roleLabel}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status Badge
                      if (user.isBlocked)
                        const Chip(label: Text("BLOQUÉ", style: TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.red),
                      const SizedBox(width: 8),
                      // Actions
                      _buildActionIcon(
                        icon: user.isBlocked ? Icons.lock : Icons.lock_open,
                        color: user.isBlocked ? Colors.red : Colors.green,
                        tooltip: user.isBlocked ? "Débloquer" : "Bloquer",
                        onPressed: () => viewModel.toggleBlockUser(user.uid, !user.isBlocked),
                      ),
                      _buildActionIcon(
                        icon: Icons.delete_outline,
                        color: Colors.grey,
                        tooltip: "Supprimer",
                        onPressed: () => _showDeleteConfirm(context, viewModel, user),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildActionIcon({required IconData icon, required Color color, required String tooltip, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  void _showUserDetails(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: AppColors.rose),
            const SizedBox(width: 10),
            const Text("Détails du compte"),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow("Nom complet", "${user.nom} ${user.prenom}"),
              _detailRow("Email", user.email),
              _detailRow("Rôle", user.roleLabel),
              _detailRow("Statut", user.isBlocked ? "Compte Bloqué" : "Actif"),
              _detailRow("Inscrit le", user.createdAt.toString().split(' ')[0]),
              if (user.role == UserRole.prestataire) ...[
                const Divider(height: 32),
                const Text("Infos Professionnelles", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.rose)),
                _detailRow("Marque", user.businessName ?? "N/A"),
                _detailRow("Domaine", user.businessType ?? "N/A"),
                _detailRow("Vérification", user.verificationStatus?.toString().split('.').last ?? "Inconnu"),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("FERMER")),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.noir, fontSize: 14),
          children: [
            TextSpan(text: "$label : ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AdminViewModel vm, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer l'utilisateur ?"),
        content: Text("Êtes-vous sûr de vouloir supprimer définitivement ${user.nom} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              vm.deleteUser(user.uid);
              Navigator.pop(context);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
