class WorkerSetupState {
  final String firstName;
  final String lastName;
  final String nationalId;
  final int? primaryServiceId;
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

  const WorkerSetupState({
    this.firstName = '',
    this.lastName = '',
    this.nationalId = '',
    this.primaryServiceId,
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
  });

  WorkerSetupState copyWith({
    String? firstName,
    String? lastName,
    String? nationalId,
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
    int? currentStep,
    String? expandingChipId,
    String? customServiceName,
    String? customServicePrice,
    bool? showCustomForm,
  }) {
    return WorkerSetupState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nationalId: nationalId ?? this.nationalId,
      primaryServiceId: primaryServiceId ?? this.primaryServiceId,
      primaryServiceName: primaryServiceName ?? this.primaryServiceName,
      selectedServiceId: selectedServiceId ?? this.selectedServiceId,
      avatarPath: avatarPath ?? this.avatarPath,
      additionalServices: additionalServices ?? this.additionalServices,
      description: description ?? this.description,
      workPhotos: workPhotos ?? this.workPhotos,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentStep: currentStep ?? this.currentStep,
      expandingChipId: expandingChipId,
      customServiceName: customServiceName,
      customServicePrice: customServicePrice,
      showCustomForm: showCustomForm ?? this.showCustomForm,
    );
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

  Map<String, dynamic> toJson() => {
    'serviceId': serviceId,
    'name': name,
    'basePrice': basePrice,
    'isCustom': isCustom,
  };
}
