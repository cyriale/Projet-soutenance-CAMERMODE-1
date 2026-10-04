import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/app_colors.dart';
import '../../models/article_model.dart';
import '../../models/reservation_model.dart';
import '../../models/user_model.dart';
import '../../models/availability_model.dart';
import '../../services/reservation_service.dart';
import '../../services/availability_service.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/dashboard_service.dart';

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
  String _selectedTimeSlot = "09:00";
  LieuPrestation _lieuType = LieuPrestation.auSalon;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;
  bool _attachMeasurements = false;
  UserModel? _userProfile;
  Position? _clientPosition;
  bool _isLocating = false;
  final _locationService = LocationService();
  final _availabilityService = AvailabilityService();
  AvailabilityModel? _providerAvailability;

  List<String> _timeSlots = ["09:00", "10:30", "11:30", "14:00", "15:30", "17:00"];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadProviderAvailability();
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Lundi';
      case 2: return 'Mardi';
      case 3: return 'Mercredi';
      case 4: return 'Jeudi';
      case 5: return 'Vendredi';
      case 6: return 'Samedi';
      case 7: return 'Dimanche';
      default: return '';
    }
  }

  Future<void> _loadProviderAvailability() async {
    final avail = await _availabilityService.getAvailability(widget.article.prestataireId);
    if (mounted) {
      setState(() {
        _providerAvailability = avail;
        _updateAvailableSlotsForDate(_selectedDate);
      });
    }
  }

  void _updateAvailableSlotsForDate(DateTime date) {
    final dayName = _getDayName(date.weekday);
    List<String> slots = [];
    if (_providerAvailability != null) {
      slots = _providerAvailability!.daySlots[dayName] ?? [];
    }
    
    if (slots.isEmpty) {
      slots = ["09:00", "10:30", "11:30", "14:00", "15:30", "17:00"];
    }

    setState(() {
      _timeSlots = List.from(slots);
      _selectedTimeSlot = _timeSlots.first;
    });
  }

  Future<void> _loadUserProfile() async {
    final auth = AuthService();
    final user = auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userProfile = UserModel.fromMap(doc.data()!, user.uid);
          if (_userProfile!.hasBodyScan && widget.article.type == ArticleType.couture) {
            _attachMeasurements = true;
          }
        });
      }
    }
  }

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
      _updateAvailableSlotsForDate(picked);
    }
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
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _confirmBooking() async {
    if (_selectedTimeSlot.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir un créneau horaire disponible.")),
      );
      return;
    }

    final auth = AuthService();
    String userId = auth.currentUser?.uid ?? "guest_${DateTime.now().millisecondsSinceEpoch}";

    setState(() => _isSubmitting = true);

    if (_providerAvailability != null) {
      final dayName = _getDayName(_selectedDate.weekday);
      final isOpen = _providerAvailability!.workingDays[dayName] ?? true;
      if (!isOpen) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ Ce prestataire est fermé le $dayName. Veuillez choisir un jour d'ouverture."),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
    }

    final resService = ReservationService();
    
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
            content: Text("⚠️ Ce créneau est déjà réservé. Veuillez en choisir un autre."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final reservation = ReservationModel(
      id: "res_${DateTime.now().millisecondsSinceEpoch}", 
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

    // Enregistrement dynamique dans Firestore
    final success = await resService.createReservation(reservation);

    // Synchronisation dans le Dashboard local
    DashboardService().reservations.insert(0, reservation);

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✨ Réservation enregistrée chez ${widget.article.prestataireNom} !"),
          backgroundColor: AppColors.succes,
          duration: const Duration(seconds: 4),
        ),
      );
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
            Center(child: Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            Text("Réserver : ${widget.article.titre}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.noir)),
            Text("Prestataire : ${widget.article.prestataireNom}", style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire)),
            const Divider(height: 24),

            // Date
            const Text("Date du rendez-vous", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: AppColors.ligne), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: AppColors.rose),
                    const SizedBox(width: 12),
                    Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const Icon(Icons.edit, size: 16, color: AppColors.rose),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Créneaux
            const Text("Choisir un horaire", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.noir, fontWeight: FontWeight.bold),
                  onSelected: (val) => setState(() => _selectedTimeSlot = slot),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),

            // Lieu
            const Text("Lieu de prestation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text("Au salon / Atelier"),
                    selected: _lieuType == LieuPrestation.auSalon,
                    selectedColor: AppColors.rose,
                    labelStyle: TextStyle(color: _lieuType == LieuPrestation.auSalon ? Colors.white : AppColors.noir),
                    onSelected: (val) => setState(() => _lieuType = LieuPrestation.auSalon),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.article.prestationADomicile)
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("À domicile"),
                      selected: _lieuType == LieuPrestation.aDomicile,
                      selectedColor: AppColors.rose,
                      labelStyle: TextStyle(color: _lieuType == LieuPrestation.aDomicile ? Colors.white : AppColors.noir),
                      onSelected: (val) => setState(() => _lieuType = LieuPrestation.aDomicile),
                    ),
                  ),
              ],
            ),
            
            if (_lieuType == LieuPrestation.aDomicile) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: "Saisissez votre adresse de livraison/prestation",
                  prefixIcon: const Icon(Icons.location_on, color: AppColors.rose),
                  suffixIcon: IconButton(
                    icon: _isLocating
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location, color: AppColors.rose),
                    tooltip: "Partager ma position GPS",
                    onPressed: _isLocating ? null : _captureClientLocation,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: "Notes ou consignes particulières (Optionnel)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rose,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("CONFIRMER MA RÉSERVATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
