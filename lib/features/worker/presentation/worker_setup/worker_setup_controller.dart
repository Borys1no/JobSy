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
    _picker = ImagePicker();
    return const WorkerSetupState();
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
}
