import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/availability_model.dart';
import '../../services/availability_service.dart';

class PrestataireDisponibilitesScreen extends StatefulWidget {
  final String prestataireId;

  const PrestataireDisponibilitesScreen({super.key, required this.prestataireId});

  @override
  State<PrestataireDisponibilitesScreen> createState() => _PrestataireDisponibilitesScreenState();
}

class _PrestataireDisponibilitesScreenState extends State<PrestataireDisponibilitesScreen> {
  final AvailabilityService _availabilityService = AvailabilityService();
  bool _isLoading = true;
  bool _isSaving = false;
  late AvailabilityModel _availability;
  
  String _selectedDayForSlots = "Lundi";

  final List<String> _daysOrder = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoading = true);
    final data = await _availabilityService.getAvailability(widget.prestataireId);
    setState(() {
      _availability = data;
      _isLoading = false;
    });
  }

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);
    final success = await _availabilityService.saveAvailability(_availability);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? "✅ Vos disponibilités ont été enregistrées !"
              : "❌ Échec de l'enregistrement."),
          backgroundColor: success ? AppColors.succes : AppColors.erreur,
        ),
      );
    }
  }

  void _toggleDay(String day) {
    final updatedDays = Map<String, bool>.from(_availability.workingDays);
    updatedDays[day] = !(updatedDays[day] ?? false);
    setState(() {
      _availability = _availability.copyWith(workingDays: updatedDays);
    });
  }

  Future<void> _showAddSlotDialog() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 09, minute: 0),
    );

    if (picked != null) {
      final formatted = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      
      final currentSlots = _availability.daySlots[_selectedDayForSlots] ?? [];
      if (currentSlots.contains(formatted)) return;
      
      final updatedDaySlots = Map<String, List<String>>.from(_availability.daySlots);
      updatedDaySlots[_selectedDayForSlots] = List<String>.from(currentSlots)..add(formatted);
      updatedDaySlots[_selectedDayForSlots]!.sort();
      
      setState(() {
        _availability = _availability.copyWith(daySlots: updatedDaySlots);
      });
    }
  }

  void _deleteSlot(String day, String slot) {
    final updatedDaySlots = Map<String, List<String>>.from(_availability.daySlots);
    if (updatedDaySlots[day] != null) {
      updatedDaySlots[day] = List<String>.from(updatedDaySlots[day]!)..remove(slot);
      setState(() {
        _availability = _availability.copyWith(daySlots: updatedDaySlots);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Mes Disponibilités", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAll,
            child: const Text("Enregistrer", style: TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.rose))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildCardSection(
                  title: "JOURS D'OUVERTURE & RÉSUMÉ",
                  icon: Icons.calendar_today,
                  child: Column(
                    children: _daysOrder.map((day) {
                      final isOpen = _availability.workingDays[day] ?? false;
                      final slots = _availability.daySlots[day] ?? [];
                      final String slotsSummary = slots.isEmpty 
                          ? "Aucun créneau" 
                          : slots.join(", ");

                      return SwitchListTile(
                        title: Text(
                          day,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          isOpen ? "Horaires : $slotsSummary" : "Fermé",
                          style: TextStyle(
                            color: isOpen ? AppColors.rose : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        value: isOpen,
                        onChanged: (_) => _toggleDay(day),
                        activeColor: AppColors.rose,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                _buildCardSection(
                  title: "CRÉNEAUX PAR JOUR",
                  icon: Icons.access_time,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _daysOrder.map((day) {
                            final isSelected = _selectedDayForSlots == day;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(day),
                                selected: isSelected,
                                onSelected: (val) { if (val) setState(() => _selectedDayForSlots = day); },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Horaires pour $_selectedDayForSlots", style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(onPressed: _showAddSlotDialog, icon: const Icon(Icons.add_circle, color: AppColors.rose)),
                        ],
                      ),
                      _buildSlotsGrid(_selectedDayForSlots),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildCardSection(
                  title: "SERVICES",
                  icon: Icons.home,
                  child: SwitchListTile(
                    title: const Text("Déplacement à domicile"),
                    value: _availability.isAvailableForHomeService,
                    onChanged: (v) => setState(() => _availability = _availability.copyWith(isAvailableForHomeService: v)),
                    activeColor: AppColors.rose,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSlotsGrid(String day) {
    final slots = _availability.daySlots[day] ?? [];
    return Wrap(
      spacing: 8,
      children: slots.map((slot) => Chip(
        label: Text(slot),
        onDeleted: () => _deleteSlot(day, slot),
        deleteIconColor: Colors.red,
      )).toList(),
    );
  }

  Widget _buildCardSection({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, size: 18, color: AppColors.rose), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
