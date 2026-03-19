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

  void updateService({int? id, String? name}) {
    state = state.copyWith(selectedServiceId: id, primaryServiceName: name);
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
    if (state.currentStep == 1) {
      final error = validateStep2();
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

  void updateSector(String value) {
    state = state.copyWith(sector: value);
  }

  void updateAddress(String value) {
    state = state.copyWith(address: value);
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

      //Subir avatar a Storage si existe
      String? avatarUrl;
      if (state.avatarPath != null) {
        final avatarFile = File(state.avatarPath!);
        final avatarExt = state.avatarPath!.split('.').last;
        final storagePath = 'avatars/$userId.$avatarExt';

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

      //2. Subir fotos de trabajos a storage
      final workPhotoUrls = <String>[];
      for (var i = 0; i < state.workPhotos.length; i++) {
        final photoPath = state.workPhotos[i];
        if (photoPath != null) {
          final photoFile = File(photoPath);
          final photoExt = photoPath.split('.').last;
          final storagePath = 'work_photos/$userId/${i}.$photoExt';

          await _supabase.storage
              .from('work_photos')
              .upload(
                storagePath,
                photoFile,
                fileOptions: const FileOptions(upsert: true),
              );
          final publicUrl = _supabase.storage
              .from('work_photos')
              .getPublicUrl(storagePath);
          workPhotoUrls.add(publicUrl);
        }
      }
      //3 Insertar/Actualizar en profiles
      await _supabase.from('profiles').upsert({
        'id': userId,
        'first_name': state.firstName,
        'last_name': state.lastName,
        'phone': '',
        'role': 'worker',
        'avatar_url': avatarUrl,
      });

      //4 Insertar en user_identity

      await _supabase.from('user_identity').upsert({
        'user_id': userId,
        'national_id': state.nationalId,
        'verified': false,
      });

      //5 Insertar en worker_profiles
      await _supabase.from('worker_profiles').upsert({
        'user_id': userId,
        'bio': state.description,
        'zone': state.sector,
        'address': state.address,
        'latitude': state.latitude,
        'longitude': state.longitude,
        'available_days': state.availableDaysAsInt,
        'available_emergency': state.availableEmergency,
      });

      //6 Insertar servicios (principal + adicionales)
      //Servicio principal

      if (state.selectedServiceId != null) {
        await _supabase.from('worker_services').upsert({
          'worker_id': userId,
          'service_id': state.selectedServiceId,
          'service_type': 'primary',
          'base_price': null,
        });
      }
      //Servicios adicionales

      for (final service in state.additionalServices) {
        if (service.serviceId != null) {
          //Servicios existente
          await _supabase.from('worker_services').insert({
            'worker_id': userId,
            'service_id': service.serviceId,
            'service_type': 'secondary',
            'base_price': service.basePrice,
          });
        } else {
          //Servicios personalizados - primero crear en services
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
}
