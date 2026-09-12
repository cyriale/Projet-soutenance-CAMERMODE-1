import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/user_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../views_models/administrateur/admin_view_model.dart';

class AdminVerificationsScreen extends StatefulWidget {
  const AdminVerificationsScreen({super.key});

  @override
  State<AdminVerificationsScreen> createState() => _AdminVerificationsScreenState();
}

class _AdminVerificationsScreenState extends State<AdminVerificationsScreen> {
  int _selectedFilterIndex = 0; // 0: En attente, 1: À corriger, 2: Vérifiés, 3: Refusés, 4: Tous
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminViewModel>();

    List<UserModel> listToDisplay;
    switch (_selectedFilterIndex) {
      case 0:
        listToDisplay = viewModel.pendingPrestataires;
        break;
      case 1:
        listToDisplay = viewModel.correctionRequestedPrestataires;
        break;
      case 2:
        listToDisplay = viewModel.verifiedPrestataires;
        break;
      case 3:
        listToDisplay = viewModel.rejectedPrestataires;
        break;
      case 4:
      default:
        listToDisplay = viewModel.allPrestataires;
        break;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      listToDisplay = listToDisplay.where((u) {
        final full = "${u.nom} ${u.prenom} ${u.businessName ?? ''} ${u.email} ${u.telephone ?? ''}".toLowerCase();
        return full.contains(q);
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Contrôle & Vérification des Prestataires", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.noir, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de filtrage par statut
          _buildFilterBar(viewModel),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: "Rechercher un prestataire (nom, email, boutique, téléphone)...",
                prefixIcon: const Icon(Icons.search, color: AppColors.rose),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchQuery = "")) 
                  : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Liste des dossiers
          Expanded(
            child: listToDisplay.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_outlined, size: 64, color: AppColors.noir.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          _getEmptyMessage(),
                          style: const TextStyle(fontSize: 16, color: AppColors.texteSecondaire),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: listToDisplay.length,
                    itemBuilder: (context, index) {
                      final user = listToDisplay[index];
                      return _buildProviderVerificationCard(context, viewModel, user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_selectedFilterIndex) {
      case 0: return "Aucun dossier en attente d'examen.";
      case 1: return "Aucun dossier en cours de correction.";
      case 2: return "Aucun prestataire validé pour le moment.";
      case 3: return "Aucun dossier refusé.";
      default: return "Aucun prestataire trouvé.";
    }
  }

  Widget _buildFilterBar(AdminViewModel vm) {
    final filters = [
      {"label": "En attente", "count": vm.pendingPrestataires.length, "color": Colors.orange},
      {"label": "À corriger", "count": vm.correctionRequestedPrestataires.length, "color": Colors.amber.shade800},
      {"label": "Vérifiés", "count": vm.verifiedPrestataires.length, "color": Colors.green},
      {"label": "Refusés", "count": vm.rejectedPrestataires.length, "color": Colors.red},
      {"label": "Tous", "count": vm.allPrestataires.length, "color": AppColors.noir},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (i) {
            final f = filters[i];
            final isSelected = _selectedFilterIndex == i;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(f["label"] as String),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white24 : (f["color"] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${f["count"]}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (f["color"] as Color),
                        ),
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                selectedColor: f["color"] as Color,
                labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.noir, fontWeight: FontWeight.bold, fontSize: 13),
                backgroundColor: Colors.grey.shade100,
                onSelected: (val) {
                  if (val) setState(() => _selectedFilterIndex = i);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProviderVerificationCard(BuildContext context, AdminViewModel viewModel, UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 28),
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête coloré avec statut
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.noir,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null || user.photoUrl!.isEmpty
                      ? Text(user.nom.isNotEmpty ? user.nom[0] : "P", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.rose))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.businessName ?? "Sans Marque Déclarée", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19)),
                      const SizedBox(height: 2),
                      Text("${user.prenom} ${user.nom}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("ID: ${user.uid}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.rose, borderRadius: BorderRadius.circular(20)),
                      child: Text(user.businessType ?? "Couture", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusBadge(user.verificationStatus),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alerte Motif précédent si existant
                if (user.rejectionReason != null && user.rejectionReason!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: user.verificationStatus == VerificationStatus.documentsACorriger
                          ? Colors.orange.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: user.verificationStatus == VerificationStatus.documentsACorriger
                            ? Colors.orange.shade300
                            : Colors.red.shade300,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          user.verificationStatus == VerificationStatus.documentsACorriger
                              ? Icons.warning_amber_rounded
                              : Icons.cancel_outlined,
                          color: user.verificationStatus == VerificationStatus.documentsACorriger
                              ? Colors.orange
                              : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.verificationStatus == VerificationStatus.documentsACorriger
                                    ? "INSTRUCTION DE CORRECTION ENVOYÉE :"
                                    : "MOTIF DU REFUS :",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: user.verificationStatus == VerificationStatus.documentsACorriger
                                      ? Colors.orange.shade900
                                      : Colors.red.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(user.rejectionReason!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Grille d'Informations Détaillées
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 650;
                    return isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildPersonalInfoSection(user)),
                              const SizedBox(width: 32),
                              Expanded(child: _buildActivitySection(context, user)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPersonalInfoSection(user),
                              const SizedBox(height: 20),
                              _buildActivitySection(context, user),
                            ],
                          );
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(),
                ),

                // Galerie de Documents avec zoom interactif
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "DOCUMENTS ET JUSTIFICATIFS (CLIQUEZ POUR ZOOMER)",
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1, fontSize: 13, color: AppColors.rose),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.zoom_in, color: AppColors.rose, size: 16),
                        SizedBox(width: 4),
                        Text("Zoom interactif disponible", style: TextStyle(fontSize: 11, color: AppColors.texteSecondaire)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 175,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildDocThumbnail(context, "Photo de profil", user.photoUrl, subtitle: "Portrait officiel"),
                      _buildDocThumbnail(context, "Pièce d'identité", user.idDocumentUrl, subtitle: "${user.idDocumentType ?? 'CNI'} • ${user.idDocumentNumber ?? ''}"),
                      _buildDocThumbnail(context, "Preuve Professionnelle", user.professionalProofUrl, subtitle: "Diplôme ou Attestation"),
                      if (!user.isWorkingAtHome) 
                        _buildDocThumbnail(context, "Photo de la boutique", user.shopProofUrl, subtitle: "Local réel"),
                      _buildDocThumbnail(context, "Selfie de sécurité", user.selfieUrl, subtitle: "Contrôle biométrique"),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                
                // Barre d'actions d'administration
                _buildActionButtons(context, viewModel, user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(VerificationStatus? status) {
    Color bg;
    String label;
    IconData icon;

    switch (status) {
      case VerificationStatus.verifie:
        bg = Colors.green;
        label = "VALIDÉ ✅";
        icon = Icons.check_circle;
        break;
      case VerificationStatus.documentsACorriger:
        bg = Colors.orange;
        label = "CORRECTION ⚠️";
        icon = Icons.edit;
        break;
      case VerificationStatus.refuse:
        bg = Colors.red;
        label = "REFUSÉ ❌";
        icon = Icons.cancel;
        break;
      case VerificationStatus.enAttente:
      case VerificationStatus.enCours:
      default:
        bg = Colors.amber.shade800;
        label = "EN ATTENTE ⏳";
        icon = Icons.hourglass_top;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(UserModel user) {
    String dobStr = "Non renseignée";
    if (user.dateNaissance != null) {
      dobStr = "${user.dateNaissance!.day.toString().padLeft(2, '0')}/${user.dateNaissance!.month.toString().padLeft(2, '0')}/${user.dateNaissance!.year}";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("COORDONNÉES PERSONNELLES", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.texteSecondaire, fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 12),
        _infoRow(Icons.email_outlined, "Email", user.email),
        _infoRow(Icons.phone_outlined, "Téléphone", user.telephone ?? "Non renseigné"),
        _infoRow(Icons.cake_outlined, "Date Naissance", dobStr),
        _infoRow(Icons.badge_outlined, "N° Document (${user.idDocumentType ?? 'CNI'})", user.idDocumentNumber ?? "N/A"),
      ],
    );
  }

  Widget _buildActivitySection(BuildContext context, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ACTIVITÉ PROFESSIONNELLE & LOCALISATION", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.texteSecondaire, fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 12),
        _infoRow(Icons.location_on_outlined, "Adresse", user.adresseActivite ?? "Non renseignée"),
        _infoRow(Icons.home_work_outlined, "Type de lieu", user.isWorkingAtHome ? "À domicile / Sans boutique" : "Boutique / Atelier physique"),
        _infoRow(Icons.calendar_month_outlined, "Inscrit le", "${user.createdAt.day.toString().padLeft(2, '0')}/${user.createdAt.month.toString().padLeft(2, '0')}/${user.createdAt.year}"),
        if (user.latitude != null && user.longitude != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: OutlinedButton.icon(
              onPressed: () => _showLocationOnMap(context, user),
              icon: const Icon(Icons.map, size: 16, color: Colors.blue),
              label: Text("Voir sur Google Maps (${user.latitude!.toStringAsFixed(4)}, ${user.longitude!.toStringAsFixed(4)})", style: const TextStyle(fontSize: 12, color: Colors.blue)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue)),
            ),
          ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.noir.withOpacity(0.6)),
          const SizedBox(width: 8),
          Text("$label : ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildDocThumbnail(BuildContext context, String label, String? url, {String? subtitle}) {
    final hasImage = url != null && url.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: hasImage ? () => _showInteractiveZoomDialog(context, url, label, subtitle) : null,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: hasImage ? AppColors.rose.withOpacity(0.5) : AppColors.ligne, width: 1.5),
                color: Colors.grey.shade100,
                image: hasImage ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover) : null,
                boxShadow: hasImage ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))] : null,
              ),
              child: !hasImage
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 30),
                          SizedBox(height: 4),
                          Text("Non fourni", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    )
                  : Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.zoom_in, color: Colors.white, size: 16),
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 140,
              child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            ),
            if (subtitle != null)
              SizedBox(
                width: 140,
                child: Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.texteSecondaire), overflow: TextOverflow.ellipsis),
              ),
          ],
        ),
      ),
    );
  }

  // --- VISIONNEUSE AVEC ZOOM INTERACTIF HAUTE RÉSOLUTION ---
  void _showInteractiveZoomDialog(BuildContext context, String url, String title, String? subtitle) {
    final TransformationController transformController = TransformationController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 800,
            height: 700,
            child: Stack(
              children: [
                // Zone interactive avec zoom et panoramique libre (0.5x à 6x)
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: transformController,
                    panEnabled: true,
                    scaleEnabled: true,
                    minScale: 0.5,
                    maxScale: 6.0,
                    child: Center(
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                  : null,
                              color: AppColors.rose,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Text("Erreur de chargement de l'image.", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ),

                // En-tête avec titre et fermeture
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            if (subtitle != null) Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        backgroundColor: Colors.black87,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Barre d'outils de zoom en bas
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white24)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.zoom_out, color: Colors.white),
                            tooltip: "Dézoomer",
                            onPressed: () {
                              transformController.value = transformController.value.scaled(0.8);
                            },
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              transformController.value = Matrix4.identity();
                            },
                            child: const Text("100% (Reset)", style: TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.zoom_in, color: Colors.white),
                            tooltip: "Zoomer",
                            onPressed: () {
                              transformController.value = transformController.value.scaled(1.25);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AdminViewModel viewModel, UserModel user) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Bouton Réexaminer si déjà statué
        if (user.verificationStatus != VerificationStatus.enAttente)
          OutlinedButton.icon(
            onPressed: () => viewModel.verifyPrestataire(user.uid, VerificationStatus.enAttente),
            icon: const Icon(Icons.restore, size: 16),
            label: const Text("REMETTRE EN ATTENTE"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade800,
              side: BorderSide(color: Colors.grey.shade400),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),

        // Bouton Refus
        OutlinedButton.icon(
          onPressed: () => _showDecisionDialog(context, viewModel, user.uid, VerificationStatus.refuse),
          icon: const Icon(Icons.cancel_outlined, size: 16),
          label: const Text("REFUSER"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),

        // Bouton Demander Correction
        OutlinedButton.icon(
          onPressed: () => _showDecisionDialog(context, viewModel, user.uid, VerificationStatus.documentsACorriger),
          icon: const Icon(Icons.edit_note, size: 18),
          label: const Text("DEMANDER CORRECTION"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange.shade800,
            side: BorderSide(color: Colors.orange.shade800),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),

        // Bouton Accepter / Valider
        ElevatedButton.icon(
          onPressed: () {
            viewModel.verifyPrestataire(user.uid, VerificationStatus.verifie);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Dossier de ${user.businessName ?? user.nom} validé avec succès !"), backgroundColor: AppColors.succes),
            );
          },
          icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
          label: const Text("ACCEPTER & VALIDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            elevation: 2,
          ),
        ),
      ],
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
            width: 650,
            height: 520,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: position, zoom: 15),
                  markers: {
                    Marker(
                      markerId: const MarkerId("shop_location"),
                      position: position,
                      infoWindow: InfoWindow(title: user.businessName ?? "Atelier Prestataire", snippet: user.adresseActivite),
                    ),
                  },
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)]),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront, color: AppColors.rose),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${user.businessName ?? 'Boutique'} • ${user.adresseActivite ?? 'Adresse sans précision'}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isDefinitive ? "Refuser le dossier ?" : "Demander une correction"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isDefinitive 
              ? "Veuillez préciser le motif du refus. Le prestataire verra cette explication sur son tableau de bord." 
              : "Précisez exactement quels documents ou informations le prestataire doit corriger. Il verra cette consigne et pourra mettre à jour son dossier immédiatement."),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: isDefinitive 
                    ? "Ex: Document d'identité illisible / Non conforme..." 
                    : "Ex: Photo CNI floue, veuillez fournir une photo nette recto/verso...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le motif est obligatoire pour informer le prestataire.")));
                return;
              }
              vm.verifyPrestataire(uid, status, reason: controller.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isDefinitive ? "Refus enregistré." : "Demande de correction transmise au prestataire."),
                  backgroundColor: isDefinitive ? Colors.red : Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDefinitive ? Colors.red : Colors.orange.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isDefinitive ? "CONFIRMER LE REFUS" : "ENVOYER LA DEMANDE DE CORRECTION", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
