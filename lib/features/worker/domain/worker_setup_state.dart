class WorkerSetupState {
  final String firstName;
  final String lastName;
  final String nationalId;
  final String phone;
  final String? primaryServiceName;
  final int? selectedServiceId; // ID de la profesión seleccionada
  final String? avatarPath; // Path local temporal
  final List<AdditionalService> additionalServices;
  final String description;
  final List<String?> workPhotos; // 3 elementos, rutas locales
  final String? avatarUrl; // URL después de subir a Supabase
  final bool isLoading;
  final String? errorMessage;
  final int currentStep; // 0, 1, 2 (para los 3 pasos)
  final String? expandingChipId; // Para controlar qué chip está expandido
  final String? customServiceName;
  final String? customServicePrice;
  final bool showCustomForm;

  final Map<int, String> servicePrices;

  // Paso 3 - Ubicación
  final bool isGettingLocation;
  final String city;
  final String sector;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? locationWKT;

  // ✅ Disponibilidad con booleanos individuales
  final bool availableMonday;
  final bool availableTuesday;
  final bool availableWednesday;
  final bool availableThursday;
  final bool availableFriday;
  final bool availableSaturday;
  final bool availableSunday;
  final bool availableEmergency; // Disponibilidad 24/7

  const WorkerSetupState({
    this.firstName = '',
    this.lastName = '',
    this.nationalId = '',
    this.phone = '',
    this.primaryServiceName,
    this.selectedServiceId,
    this.avatarPath,
    this.additionalServices = const [],
    this.description = '',
    this.workPhotos = const [null, null, null],
    this.avatarUrl,
    this.isLoading = false,
    this.errorMessage,
    this.currentStep = 0,
    this.expandingChipId,
    this.customServiceName,
    this.customServicePrice,
    this.showCustomForm = false,
    // Paso 3
    this.isGettingLocation = false,
    this.city = 'Guayaquil',
    this.sector = '',
    this.address = '',
    this.latitude,
    this.longitude,
    this.locationWKT,
    this.availableMonday = true,
    this.availableTuesday = true,
    this.availableWednesday = true,
    this.availableThursday = true,
    this.availableFriday = true,
    this.availableSaturday = false,
    this.availableSunday = false,
    this.availableEmergency = false,

    this.servicePrices = const {},
  });

  WorkerSetupState copyWith({
    String? firstName,
    String? lastName,
    String? nationalId,
    String? phone,
    int? primaryServiceId,
    String? primaryServiceName,
    int? selectedServiceId,
    String? avatarPath,
    List<AdditionalService>? additionalServices,
    String? description,
    List<String?>? workPhotos,
    String? avatarUrl,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    int? currentStep,
    String? expandingChipId,
    String? customServiceName,
    String? customServicePrice,
    bool? showCustomForm,
    // Paso 3
    bool? isGettingLocation,
    String? city,
    String? sector,
    String? address,
    double? latitude,
    double? longitude,
    String? locationWKT,
    bool? availableMonday,
    bool? availableTuesday,
    bool? availableWednesday,
    bool? availableThursday,
    bool? availableFriday,
    bool? availableSaturday,
    bool? availableSunday,
    bool? availableEmergency,
    Map<int, String>? servicePrices,
  }) {
    return WorkerSetupState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nationalId: nationalId ?? this.nationalId,
      phone: phone ?? this.phone,
      primaryServiceName: primaryServiceName ?? this.primaryServiceName,
      selectedServiceId: selectedServiceId ?? this.selectedServiceId,
      avatarPath: avatarPath ?? this.avatarPath,
      additionalServices: additionalServices ?? this.additionalServices,
      description: description ?? this.description,
      workPhotos: (workPhotos ?? this.workPhotos).length == 3
          ? workPhotos ?? this.workPhotos
          : this.workPhotos,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,

      currentStep: currentStep ?? this.currentStep,
      expandingChipId: expandingChipId ?? this.expandingChipId,
      customServiceName: customServiceName ?? this.customServiceName,
      customServicePrice: customServicePrice ?? this.customServicePrice,
      showCustomForm: showCustomForm ?? this.showCustomForm,
      // Paso 3
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
      city: city ?? this.city,
      sector: sector ?? this.sector,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationWKT: locationWKT ?? this.locationWKT,
      availableMonday: availableMonday ?? this.availableMonday,
      availableTuesday: availableTuesday ?? this.availableTuesday,
      availableWednesday: availableWednesday ?? this.availableWednesday,
      availableThursday: availableThursday ?? this.availableThursday,
      availableFriday: availableFriday ?? this.availableFriday,
      availableSaturday: availableSaturday ?? this.availableSaturday,
      availableSunday: availableSunday ?? this.availableSunday,
      availableEmergency: availableEmergency ?? this.availableEmergency,
      servicePrices: servicePrices ?? this.servicePrices,
    );
  }

  // ========== GETTERS Y HELPERS ==========

  // ✅ 1. Días disponibles como List<String> (para mostrar en UI)
  List<String> get availableDaysAsString {
    final days = <String>[];
    if (availableMonday) days.add('Lunes');
    if (availableTuesday) days.add('Martes');
    if (availableWednesday) days.add('Miércoles');
    if (availableThursday) days.add('Jueves');
    if (availableFriday) days.add('Viernes');
    if (availableSaturday) days.add('Sábado');
    if (availableSunday) days.add('Domingo');
    return days;
  }

  // ✅ 2. Días disponibles como List<int> (para guardar en DB)
  List<int> get availableDaysAsInt {
    final days = <int>[];
    if (availableMonday) days.add(1); // Lunes = 1
    if (availableTuesday) days.add(2); // Martes = 2
    if (availableWednesday) days.add(3); // Miércoles = 3
    if (availableThursday) days.add(4); // Jueves = 4
    if (availableFriday) days.add(5); // Viernes = 5
    if (availableSaturday) days.add(6); // Sábado = 6
    if (availableSunday) days.add(0); // Domingo = 0
    days.sort();
    return days;
  }

  // ✅ 3. Helper: Obtener nombre del día por número
  String getDayName(int day) {
    const dayNames = [
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
    ];
    return dayNames[day];
  }

  // ✅ 4. Helper: Verificar si un día específico está disponible
  bool isDayAvailable(int day) {
    return availableDaysAsInt.contains(day);
  }

  // ✅ 5. Helper: Formato legible para mostrar
  String get formattedAvailableDays {
    final days = availableDaysAsString; // ✅ Ahora sí existe
    if (days.isEmpty) return 'No disponible';
    if (days.length == 7) return 'Todos los días';
    return days.join(', ');
  }

  // ✅ 6. Helper: Verificar si trabaja fines de semana
  bool get hasWeekendAvailability {
    return availableSaturday || availableSunday;
  }

  // ✅ 7. Helper: Verificar si trabaja hoy
  bool get isAvailableToday {
    final today = DateTime.now().weekday; // 1=Lunes, 7=Domingo
    switch (today) {
      case DateTime.monday:
        return availableMonday;
      case DateTime.tuesday:
        return availableTuesday;
      case DateTime.wednesday:
        return availableWednesday;
      case DateTime.thursday:
        return availableThursday;
      case DateTime.friday:
        return availableFriday;
      case DateTime.saturday:
        return availableSaturday;
      case DateTime.sunday:
        return availableSunday;
      default:
        return false;
    }
  }

  // ✅ 8. Helper: Obtener cantidad de días disponibles
  int get availableDaysCount {
    return availableDaysAsInt.length;
  }

  // ✅ 9. Helper: Verificar si está disponible algún día
  bool get hasAvailability {
    return availableDaysAsInt.isNotEmpty;
  }
}

class AdditionalService {
  final int? serviceId;
  final String name;
  final double basePrice;
  final bool isCustom;

  const AdditionalService({
    this.serviceId,
    required this.name,
    required this.basePrice,
    this.isCustom = false,
  });

  AdditionalService copyWith({
    int? serviceId,
    String? name,
    double? basePrice,
    bool? isCustom,
  }) {
    return AdditionalService(
      serviceId: serviceId ?? this.serviceId,
      name: name ?? this.name,
      basePrice: basePrice ?? this.basePrice,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toDbMap(String userId) => {
    'worker_id': userId,
    'service_id': serviceId,
    'base_price': basePrice,
  };
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdditionalService &&
          serviceId == other.serviceId &&
          name == other.name &&
          basePrice == other.basePrice &&
          isCustom == other.isCustom;

  @override
  int get hashCode =>
      serviceId.hashCode ^
      name.hashCode ^
      basePrice.hashCode ^
      isCustom.hashCode;
}
