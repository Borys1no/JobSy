import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_client.dart';
import '../../domain/worker_setup_state.dart';

part 'worker_setup_controller.g.dart';

@riverpod
class WorkerSetupController extends _$WorkerSetupController {
  late final ImagePicker _picker;

  @override
  WorkerSetupState build() {
    //Cargar datos iniciales si venimos del paso 1

    final previousState = ref.watch(workerSetupStateProvider);
    return previousState ?? const WorkerSetupState();
  }

  SupabaseClient get _supabase => ref.read(supabaseClientProvider);

  // ✅ TODOS LOS MÉTODOS DENTRO DE LA CLASE

  // Validación de cédula
  bool _validateEcuadorianId(String id) {
    if (id.length != 10) return false;

    // Los dos primeros dígitos son la provincia (01-24)
    int province = int.parse(id.substring(0, 2));
    if (province < 1 || province > 24) return false;

    // El tercer dígito es menor a 6
    int thirdDigit = int.parse(id[2]);
    if (thirdDigit > 5) return false;

    // Algoritmo módulo 10
    int total = 0;
    for (int i = 0; i < 9; i++) {
      int digit = int.parse(id[i]);
      if (i % 2 == 0) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      total += digit;
    }
    int lastDigit = int.parse(id[9]);
    int calculatedDigit = (total % 10 == 0) ? 0 : 10 - (total % 10);

    return lastDigit == calculatedDigit;
  }

  // Validar el formulario del paso 1
  String? validatedStep1({
    required String firstName,
    required String lastName,
    required String nationalId,
    required int? serviceId,
  }) {
    if (firstName.isEmpty) return 'Ingresa tus nombres';
    if (lastName.isEmpty) return 'Ingresa tus apellidos';
    if (nationalId.isEmpty) return 'Ingresa tu cédula';
    if (!_validateEcuadorianId(nationalId)) return 'Cédula inválida';
    if (serviceId == null) return 'Selecciona una profesión';
    return null;
  }

  // Actualizar campos
  void updateFirstName(String value) {
    state = state.copyWith(firstName: value);
  }

  void updateLastName(String value) {
    state = state.copyWith(lastName: value);
  }

  void updateNationalId(String value) {
    state = state.copyWith(nationalId: value);
  }

  void updateServiceId(int? serviceId) {
    state = state.copyWith(selectedServiceId: serviceId);
  }

  // Seleccionar imagen de la galería
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024, // Corregido: maxWidth (no maxWith)
        maxHeight: 1024, // Corregido: maxHeight (no maxHeigth)
        imageQuality: 85, // ImagesPicker usa quality, no imageQuality
      );

      if (image != null) {
        state = state.copyWith(avatarPath: image.path);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al seleccionar imagen: $e');
    }
  }

  //control de chip expandibles

  void setExpadingChip(String? chipId) {
    state = state.copyWith(expandingChipId: chipId);
  }

  //Agregar servicio popular con precio
  void addPopularService({
    required int serviceId,
    required String serviceName,
    required double price,
  }) {
    final newService = AdditionalService(
      serviceId: serviceId,
      name: serviceName,
      basePrice: price,
      isCustom: false,
    );
    final updatedServices = List<AdditionalService>.from(
      state.additionalServices,
    )..add(newService);
    state = state.copyWith(
      additionalServices: updatedServices,
      expandingChipId: null,
    );
  }

  //Eliminar servicio adicional
  void removeAdditionalService(int index) {
    final updatedServices = List<AdditionalService>.from(
      state.additionalServices,
    )..removeAt(index);
    state = state.copyWith(additionalServices: updatedServices);
  }

  //control del formulario de servicio personalizado
  void toggleCustomForm() {
    state = state.copyWith(
      showCustomForm: !state.showCustomForm,
      customServiceName: '',
      customServicePrice: '',
      expandingChipId: null,
    );
  }

  void updateCustomServiceName(String value) {
    state = state.copyWith(customServiceName: value);
  }

  void updateCustomServicePrice(String value) {
    //Permitir solo numeros y un punto decimal
    final filtered = value.replaceAll(RegExp(r'[^\d.]'), '');
    //Evitar multiples puntos decimales
    if (filtered.split('.').length > 2) return;
    state = state.copyWith(customServicePrice: filtered);
  }

  //Agregar servicio personalizado
  Future<void> addCustomService() async {
    if (state.customServiceName == null || state.customServiceName!.isEmpty) {
      state = state.copyWith(errorMessage: 'Ingresa el nombre del servicio');
      return;
    }

    final price = double.tryParse(state.customServicePrice ?? '');
    if (price == null || price <= 0) {
      state = state.copyWith(errorMessage: 'Ingresa un precio válido');
      return;
    }

    //Por ahora solo se guarda en estado local
    final newService = AdditionalService(
      serviceId: null,
      name: state.customServiceName!,
      basePrice: price,
      isCustom: true,
    );

    final updateServices = List<AdditionalService>.from(
      state.additionalServices,
    )..add(newService);

    state = state.copyWith(
      additionalServices: updateServices,
      showCustomForm: false,
      customServiceName: '',
      customServicePrice: '',
      errorMessage: null,
    );
  }

  //Descripcion breve
  void updateDescription(String value) {
    if (value.length <= 500) {
      state = state.copyWith(description: value);
    }
  }

  //Fotos de trabajos
  Future<void> pickWorkPhoto(int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        final updatePhotos = List<String?>.from(state.workPhotos);
        updatePhotos[index] = image.path;
        state = state.copyWith(workPhotos: updatePhotos);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al seleccionar imagen');
    }
  }

  //Validar antes de continuar
  String? validateStep2() {
    if (state.description.isEmpty) {
      return 'Agrega una descripción breve de tu experiencia';
    }
    if (state.workPhotos.any((photo) => photo == null)) {
      return 'Debes subir las 3 fotos de trabajos realizados';
    }

    return null;
  }

  // Avanzar al siguiente paso (validamos antes)
  Future<bool> goToNextStep() async {
    if (state.currentStep == 0) {
      final error = validatedStep1(
        firstName: state.firstName,
        lastName: state.lastName,
        nationalId: state.nationalId,
        serviceId: state.selectedServiceId,
      );

      if (error != null) {
        state = state.copyWith(errorMessage: error);
        return false;
      }
    }

    state = state.copyWith(
      currentStep: state.currentStep + 1,
      errorMessage: null,
    );
    return true;
  }

  //Volver al paso anterior
  void goToPreviousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        errorMessage: null,
      );
    }
  }
}
