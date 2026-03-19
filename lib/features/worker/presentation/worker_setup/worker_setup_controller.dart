import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_client.dart';
import '../../domain/worker_setup_state.dart';
import 'package:riverpod/riverpod.dart';

part 'worker_setup_controller.g.dart';

@riverpod
class WorkerSetupController extends _$WorkerSetupController {
  late final ImagePicker _picker;

  @override
  WorkerSetupState build() {
    //Cargar datos iniciales si venimos del paso 1
    _picker = ImagePicker();
    return const WorkerSetupState();
  }

  SupabaseClient get _supabase => ref.read(supabaseClientProvider);

  // ✅ TODOS LOS MÉTODOS DENTRO DE LA CLASE

  // Validación de cédula
  bool _validateEcuadorianId(String id) {
    if (id.length != 10) return false;

    if (!RegExp(r'^\d{10}$').hasMatch(id)) return false;

    // Los dos primeros dígitos son la provincia (01-24)
    final province = int.tryParse(id.substring(0, 2));
    if (province == null || province < 1 || province > 24) return false;
    final thirdDigit = int.tryParse(id[2]);
    if (thirdDigit == null || thirdDigit > 5) return false;
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
    state = state.copyWith(firstName: value, errorMessage: null);
  }

  void updateLastName(String value) {
    state = state.copyWith(lastName: value, errorMessage: null);
  }

  void updateNationalId(String value) {
    state = state.copyWith(nationalId: value, errorMessage: null);
  }

  void updateService({int? id, String? name}) {
    state = state.copyWith(
      selectedServiceId: id,
      primaryServiceName: name,
      errorMessage: null,
    );
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
    final existingIndex = state.additionalServices.indexWhere(
      (s) => s.serviceId == serviceId,
    );

    final updatedServices = List<AdditionalService>.from(
      state.additionalServices,
    );

    if (existingIndex != -1) {
      updatedServices[existingIndex] = AdditionalService(
        serviceId: serviceId,
        name: serviceName,
        basePrice: price,
        isCustom: false,
      );
    } else {
      updatedServices.add(
        AdditionalService(
          serviceId: serviceId,
          name: serviceName,
          basePrice: price,
          isCustom: false,
        ),
      );
    }

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
    state = state.copyWith(customServiceName: value, errorMessage: null);
  }

  void updateCustomServicePrice(String value) {
    //Permitir solo numeros y un punto decimal
    final filtered = value.replaceAll(RegExp(r'[^\d.]'), '');
    //Evitar multiples puntos decimales
    if (filtered.split('.').length > 2) return;
    state = state.copyWith(customServicePrice: filtered, errorMessage: null);
  }

  //Agregar servicio personalizado
  Future<void> addCustomService() async {
    final exist = state.additionalServices.any(
      (s) => s.name.toLowerCase() == state.customServiceName!.toLowerCase(),
    );
    if (exist) {
      state = state.copyWith(errorMessage: 'Este servicio ya fue agregado');
      return;
    }
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
      state = state.copyWith(description: value, errorMessage: null);
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
        state = state.copyWith(workPhotos: updatePhotos, errorMessage: null);
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
    if (state.currentStep == 1) {
      final error = validateStep2();
      if (error != null) {
        state = state.copyWith(errorMessage: error);
        return false;
      }
    }
    if (state.currentStep < 2) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        errorMessage: null,
      );
    }
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

  void updateSector(String value) {
    state = state.copyWith(sector: value, errorMessage: null);
  }

  void updateAddress(String value) {
    state = state.copyWith(address: value, errorMessage: null);
  }

  void toggleDay(int day) {
    switch (day) {
      case 0: // Domingo
        state = state.copyWith(availableSunday: !state.availableSunday);
        break;
      case 1: // Lunes
        state = state.copyWith(availableMonday: !state.availableMonday);
        break;
      case 2: // Martes
        state = state.copyWith(availableTuesday: !state.availableTuesday);
        break;
      case 3: // Miércoles
        state = state.copyWith(availableWednesday: !state.availableWednesday);
        break;
      case 4: // Jueves
        state = state.copyWith(availableThursday: !state.availableThursday);
        break;
      case 5: // Viernes
        state = state.copyWith(availableFriday: !state.availableFriday);
        break;
      case 6: // Sábado
        state = state.copyWith(availableSaturday: !state.availableSaturday);
        break;
    }
  }

  void toggleEmergency() {
    state = state.copyWith(availableEmergency: !state.availableEmergency);
  }

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isGettingLocation: true, errorMessage: null);

    try {
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        latitude: -2.170998,
        longitude: -79.922359,
        sector: 'Urdesa',
        address: 'Av. Principal y Calle Secundaria',
        isGettingLocation: false,
      );
    } catch (e) {
      state = state.copyWith(
        isGettingLocation: false,
        errorMessage: 'No se pudo obtener la ubicación',
      );
    }
  }

  String? validateStep3() {
    if (state.sector.isEmpty) {
      return 'Selecciona o ingresa tu sector';
    }
    if (state.address.isEmpty) {
      return 'Ingresa tu dirección';
    }
    if (state.availableDaysAsInt.isEmpty) {
      return 'Selecciona al menos un día de disponibilidad';
    }
    return null;
  }

  //Guardar todo en Supabase (al finalizar)

  Future<bool> saveWorkerProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      // =========================
      // 1. SUBIR AVATAR
      // =========================
      String? avatarUrl;

      if (state.avatarPath != null) {
        final avatarFile = File(state.avatarPath!);
        final avatarExt = state.avatarPath!.split('.').last;
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        final storagePath = 'avatars/$userId/$timestamp.$avatarExt';

        await _supabase.storage
            .from('profiles')
            .upload(
              storagePath,
              avatarFile,
              fileOptions: const FileOptions(upsert: true),
            );

        avatarUrl = _supabase.storage
            .from('profiles')
            .getPublicUrl(storagePath);
      }

      // =========================
      // 2. SUBIR FOTOS EN PARALELO 🚀
      // =========================
      final uploadFutures = <Future<String>>[];

      for (var i = 0; i < state.workPhotos.length; i++) {
        final path = state.workPhotos[i];

        if (path != null) {
          uploadFutures.add(_uploadWorkPhoto(path, userId, i));
        }
      }

      final workPhotoUrls = await Future.wait(uploadFutures);

      // =========================
      // 3. GUARDAR DATOS (ORDEN SEGURO)
      // =========================

      // profiles
      await _supabase.from('profiles').upsert({
        'id': userId,
        'first_name': state.firstName,
        'last_name': state.lastName,
        'phone': '',
        'role': 'worker',
        'avatar_url': avatarUrl,
      });

      // identidad
      await _supabase.from('user_identity').upsert({
        'user_id': userId,
        'national_id': state.nationalId,
        'verified': false,
      });

      // worker profile
      await _supabase.from('worker_profiles').upsert({
        'user_id': userId,
        'bio': state.description,
        'zone': state.sector,
        'address': state.address,
        'latitude': state.latitude,
        'longitude': state.longitude,
        'available_days': state.availableDaysAsInt,
        'available_emergency': state.availableEmergency,
        'work_photos': workPhotoUrls, // 🔥 guardas URLs directamente
      });

      // =========================
      // 4. SERVICIO PRINCIPAL
      // =========================
      if (state.selectedServiceId != null) {
        await _supabase.from('worker_services').upsert({
          'worker_id': userId,
          'service_id': state.selectedServiceId,
          'service_type': 'primary',
          'base_price': null,
        });
      }

      // =========================
      // 5. SERVICIOS ADICIONALES
      // =========================
      for (final service in state.additionalServices) {
        if (service.serviceId != null) {
          await _supabase.from('worker_services').insert({
            'worker_id': userId,
            'service_id': service.serviceId,
            'service_type': 'secondary',
            'base_price': service.basePrice,
          });
        } else {
          final newService = await _supabase
              .from('services')
              .insert({'name': service.name})
              .select('id')
              .single();

          await _supabase.from('worker_services').insert({
            'worker_id': userId,
            'service_id': newService['id'],
            'service_type': 'secondary',
            'base_price': service.basePrice,
          });
        }
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al guardar: $e',
      );
      return false;
    }
  }

  Future<String> _uploadWorkPhoto(String path, String userId, int index) async {
    final file = File(path);
    final ext = path.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final storagePath = 'work_photos/$userId/${index}_$timestamp.$ext';

    await _supabase.storage
        .from('work_photos')
        .upload(
          storagePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from('work_photos').getPublicUrl(storagePath);
  }
}
