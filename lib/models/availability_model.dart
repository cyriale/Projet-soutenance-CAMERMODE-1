class AvailabilityModel {
  final String prestataireId;
  final Map<String, bool> workingDays;
  
  // Créneaux spécifiques par jour : {'Lundi': ['09:00', '11:00'], ...}
  final Map<String, List<String>> daySlots;
  
  final bool isAvailableForHomeService;
  final String notes;

  AvailabilityModel({
    required this.prestataireId,
    required this.workingDays,
    required this.daySlots,
    this.isAvailableForHomeService = true,
    this.notes = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'prestataireId': prestataireId,
      'workingDays': workingDays,
      'daySlots': daySlots,
      'isAvailableForHomeService': isAvailableForHomeService,
      'notes': notes,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory AvailabilityModel.fromMap(Map<String, dynamic> map, String prestataireId) {
    // Jours de travail
    Map<String, bool> days = {};
    if (map['workingDays'] != null && map['workingDays'] is Map) {
      (map['workingDays'] as Map).forEach((key, value) {
        days[key.toString()] = value == true;
      });
    } else {
      days = {
        'Lundi': true,
        'Mardi': true,
        'Mercredi': true,
        'Jeudi': true,
        'Vendredi': true,
        'Samedi': true,
        'Dimanche': false,
      };
    }

    // Créneaux par jour
    Map<String, List<String>> slots = {};
    if (map['daySlots'] != null && map['daySlots'] is Map) {
      (map['daySlots'] as Map).forEach((key, value) {
        if (value is List) {
          slots[key.toString()] = List<String>.from(value.map((e) => e.toString()));
        }
      });
    } else {
      final List<String> defaultTimes = ["09:00", "11:00", "14:00", "16:00"];
      for (var day in ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche']) {
        slots[day] = List.from(defaultTimes);
      }
    }

    return AvailabilityModel(
      prestataireId: prestataireId,
      workingDays: days,
      daySlots: slots,
      isAvailableForHomeService: map['isAvailableForHomeService'] ?? true,
      notes: map['notes'] ?? "",
    );
  }

  factory AvailabilityModel.defaultAvailability(String prestataireId) {
    final List<String> defaultTimes = ["09:00", "11:00", "14:00", "16:00"];
    return AvailabilityModel(
      prestataireId: prestataireId,
      workingDays: {
        'Lundi': true,
        'Mardi': true,
        'Mercredi': true,
        'Jeudi': true,
        'Vendredi': true,
        'Samedi': true,
        'Dimanche': false,
      },
      daySlots: {
        'Lundi': List.from(defaultTimes),
        'Mardi': List.from(defaultTimes),
        'Mercredi': List.from(defaultTimes),
        'Jeudi': List.from(defaultTimes),
        'Vendredi': List.from(defaultTimes),
        'Samedi': List.from(defaultTimes),
        'Dimanche': [],
      },
      isAvailableForHomeService: true,
      notes: "",
    );
  }

  AvailabilityModel copyWith({
    Map<String, bool>? workingDays,
    Map<String, List<String>>? daySlots,
    bool? isAvailableForHomeService,
    String? notes,
  }) {
    return AvailabilityModel(
      prestataireId: prestataireId,
      workingDays: workingDays ?? Map<String, bool>.from(this.workingDays),
      daySlots: daySlots ?? Map<String, List<String>>.from(this.daySlots),
      isAvailableForHomeService: isAvailableForHomeService ?? this.isAvailableForHomeService,
      notes: notes ?? this.notes,
    );
  }
}
