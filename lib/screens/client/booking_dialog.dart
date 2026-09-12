import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/app_colors.dart';
import '../../models/article_model.dart';
import '../../models/reservation_model.dart';
import '../../models/user_model.dart';
import '../../services/reservation_service.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';

class BookingDialog extends StatefulWidget {
  final ArticleModel article;

  const BookingDialog({super.key, required this.article});

  static Future<void> show(BuildContext context, ArticleModel article) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingDialog(article: article),
    );
  }

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeSlot = "10:00";
  LieuPrestation _lieuType = LieuPrestation.auSalon;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;
  bool _attachMeasurements = false;
  UserModel? _userProfile;
  Position? _clientPosition;
  bool _isLocating = false;
  final _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final auth = AuthService();
    final user = auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userProfile = UserModel.fromMap(doc.data()!, user.uid);
          // Si l'utilisateur a un scan, on active l'option par défaut pour la couture
          if (_userProfile!.hasBodyScan && widget.article.type == ArticleType.couture) {
            _attachMeasurements = true;
          }
        });
      }
    }
  }

  final List<String> _timeSlots = [
    "09:00",
    "10:30",
    "12:00",
    "14:00",
    "15:30",
    "17:00",
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.rose,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _confirmBooking() async {
    final auth = AuthService();
    final userId = auth.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isSubmitting = true);

    final resService = ReservationService();
    
    // Vérification de la disponibilité du créneau
    final isTaken = await resService.isSlotTaken(
      prestataireId: widget.article.prestataireId, 
      date: _selectedDate, 
      heure: _selectedTimeSlot
    );

    if (isTaken) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Ce créneau est déjà réservé pour ce prestataire à cette date. Veuillez choisir une autre heure ou une autre date."),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final reservation = ReservationModel(
      id: "", // Généré par Firestore
      userId: userId,
      prestataireId: widget.article.prestataireId,
      prestataireNom: widget.article.prestataireNom,
      prestatairePhoto: widget.article.prestatairePhoto,
      prestataireAdresse: widget.article.prestataireAdresse,
      serviceTitre: widget.article.titre,
      articleImageUrl: widget.article.imageUrl,
      date: _selectedDate,
      heure: _selectedTimeSlot,
      lieuType: _lieuType,
      adresseClient: _lieuType == LieuPrestation.aDomicile 
          ? _addressController.text.trim() 
          : widget.article.prestataireAdresse,
      notes: _notesController.text.trim(),
      prixEstime: widget.article.prix,
      status: ReservationStatus.enAttente,
      attachedMeasurements: _attachMeasurements ? {
        'tourPoitrine': _userProfile?.tourPoitrine ?? 0,
        'tourTaille': _userProfile?.tourTaille ?? 0,
        'tourHanche': _userProfile?.tourHanche ?? 0,
        'largeurEpaules': _userProfile?.largeurEpaules ?? 0,
      } : null,
      clientLatitude: _clientPosition?.latitude,
      clientLongitude: _clientPosition?.longitude,
    );

    final success = await resService.createReservation(reservation);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Demande de rendez-vous envoyée à ${widget.article.prestataireNom} !",
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.succes,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la réservation. Réessayez.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de drag
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Titre & Sous-titre
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.rose.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_month, color: AppColors.rose, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Réserver une prestation",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.noir,
                        ),
                      ),
                      Text(
                        widget.article.titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.texteSecondaire,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.ligne),
            const SizedBox(height: 12),

            // Prestataire Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.roseClair,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.rose.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.article.prestatairePhoto),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.article.prestataireNom,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.article.prestataireVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Colors.blue, size: 16),
                            ],
                          ],
                        ),
                        Text(
                          widget.article.prestataireAdresse,
                          style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${widget.article.prix.toInt()} FCFA",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.rose,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Date
            const Text(
              "Date souhaitée",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.noir),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.ligne),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: AppColors.rose),
                    const SizedBox(width: 12),
                    Text(
                      "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const Spacer(),
                    const Text("Modifier", style: TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Créneaux horaires
            const Text(
              "Créneau horaire disponible",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.noir),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedTimeSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  selectedColor: AppColors.rose,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.noir,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.grey[100],
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedTimeSlot = slot);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Lieu de la prestation
            const Text(
              "Lieu de prestation",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.noir),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _lieuType = LieuPrestation.auSalon),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: _lieuType == LieuPrestation.auSalon ? AppColors.rose : AppColors.ligne,
                        width: _lieuType == LieuPrestation.auSalon ? 2 : 1,
                      ),
                      backgroundColor: _lieuType == LieuPrestation.auSalon ? AppColors.rose.withValues(alpha: 0.08) : Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Au salon / Atelier", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                if (widget.article.prestationADomicile)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _lieuType = LieuPrestation.aDomicile),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: _lieuType == LieuPrestation.aDomicile ? AppColors.rose : AppColors.ligne,
                          width: _lieuType == LieuPrestation.aDomicile ? 2 : 1,
                        ),
                        backgroundColor: _lieuType == LieuPrestation.aDomicile ? AppColors.rose.withValues(alpha: 0.08) : Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("À domicile 🏠", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
            if (_lieuType == LieuPrestation.aDomicile) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: "Votre adresse complète (Quartier, repère)",
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.location_on, color: AppColors.rose),
                  suffixIcon: IconButton(
                    icon: _isLocating 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.my_location, color: _clientPosition != null ? Colors.green : AppColors.rose),
                    onPressed: _captureClientLocation,
                    tooltip: "Partager ma position GPS",
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.ligne)),
                ),
              ),
              if (_clientPosition != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    "✅ Position GPS capturée avec succès",
                    style: TextStyle(color: Colors.green[700], fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
            const SizedBox(height: 16),

            // Instructions / Notes
            const Text(
              "Instructions ou précisions pour l'artisan (facultatif)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.noir),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Ex : Longueur souhaitée, apporter du tissu, etc.",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.ligne)),
              ),
            ),
            const SizedBox(height: 14),

            // Option joindre mesures 3D
            if (_userProfile?.hasBodyScan ?? false)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.rose.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.rose.withValues(alpha: 0.2)),
                ),
                child: CheckboxListTile(
                  value: _attachMeasurements,
                  onChanged: (v) => setState(() => _attachMeasurements = v!),
                  title: const Text("Joindre mes mesures 3D", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text("Permet au styliste de préparer la coupe en avance", style: TextStyle(fontSize: 12)),
                  activeColor: AppColors.rose,
                ),
              ),

            // Notice Aucun Paiement
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Aucun paiement en ligne. Le règlement s'effectue directement avec l'artisan lors de la prestation.",
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bouton Confirmer
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rose,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "CONFIRMER LA DEMANDE",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureClientLocation() async {
    setState(() => _isLocating = true);
    try {
      final pos = await _locationService.getCurrentLocation();
      setState(() {
        _clientPosition = pos;
        if (pos != null) {
          _addressController.text = "Position GPS partagée";
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => _isLocating = false);
    }
  }
}
