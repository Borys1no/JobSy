class WorkerSetupState {
  final String firstName;
  final String lastName;
  final String nationalId;
  final int? selectedServiceId; // ID de la profesión seleccionada
  final String? avatarPath; // Path local temporal
  final String? avatarUrl; // URL después de subir a Supabase
  final bool isLoading;
  final String? errorMessage;
  final int currentStep; // 0, 1, 2 (para los 3 pasos)

  const WorkerSetupState({
    this.firstName = '',
    this.lastName = '',
    this.nationalId = '',
    this.selectedServiceId,
    this.avatarPath,
    this.avatarUrl,
    this.isLoading = false,
    this.errorMessage,
    this.currentStep = 0,
  });

  WorkerSetupState copyWith({
    String? firstName,
    String? lastName,
    String? nationalId,
    int? selectedServiceId,
    String? avatarPath,
    String? avatarUrl,
    bool? isLoading,
    String? errorMessage,
    int? currentStep,
  }) {
    return WorkerSetupState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nationalId: nationalId ?? this.nationalId,
      selectedServiceId: selectedServiceId ?? this.selectedServiceId,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}
