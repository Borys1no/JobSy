import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:jobsy/features/worker/domain/worker_home_state.dart';
import 'package:jobsy/features/worker/domain/review.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

part 'worker_home_controller.g.dart';

@riverpod
class WorkerHomeController extends _$WorkerHomeController {
  SupabaseClient get _supabase => ref.read(supabaseProvider);

  @override
  WorkerHomeState build() {
    Future.microtask(() => loadWorkerData());
    return WorkerHomeState.initial();
  }

  Future<void> loadWorkerData() async {
    try {
      state = state.copyWith(isLoading: true);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Perfil
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      // Worker profile
      final workerProfile = await _supabase
          .from('worker_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      // Servicios primarios
      final services = await _supabase
          .from('worker_services')
          .select('services(name)')
          .eq('worker_id', userId)
          .eq('service_type', 'primary');

      final skills = services
          .map<String>((s) => s['services']['name'] as String? ?? '')
          .toList();

      // Trabajos adicionales (worker_tasks)
      final workerTasks = await _supabase
          .from('worker_tasks')
          .select('tasks(name), base_price')
          .eq('worker_id', userId);

      final additionalJobs = workerTasks
          .map(
            (t) => AdditionalJob(
              name: t['tasks']?['name'] ?? '',
              basePrice: t['base_price'] as double?,
            ),
          )
          .toList();

      // Servicios personalizados (custom_services)
      final customSvcs = await _supabase
          .from('custom_services')
          .select('name, base_price')
          .eq('worker_id', userId);

      final customServices = customSvcs
          .map(
            (s) => AdditionalJob(
              name: s['name'] ?? '',
              basePrice: s['base_price'] as double?,
            ),
          )
          .toList();

      // Tasks disponibles
      final tasks = await _supabase
          .from('tasks')
          .select('id, name')
          .eq('is_popular', true)
          .order('name');

      final availableTasks = tasks
          .map(
            (t) => TaskItem(id: t['id'] as String, name: t['name'] as String),
          )
          .toList();

      // Fotos de trabajo
      final photosRaw = workerProfile['work_photos'] as List? ?? [];
      final workPhotos = photosRaw
          .map((url) => WorkPhoto(url: url as String))
          .toList();

      // Reseñas
      List<Review> reviews;
      final reviewsData = await _supabase
          .from('reviews')
          .select('''
            id,
            rating,
            comment,
            created_at,
            client:profiles(
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .eq('worker_id', userId)
          .order('created_at', ascending: false);

      if (reviewsData.isEmpty) {
        reviews = _getStaticReviews();
      } else {
        reviews = reviewsData.map((r) {
          final client = r['client'] as Map<String, dynamic>? ?? {};
          return Review(
            id: r['id'] as String,
            clientName:
                '${client['first_name'] ?? ''} ${client['last_name'] ?? ''}'
                    .trim(),
            clientAvatar: client['avatar_url'] as String?,
            rating: (r['rating'] as num).toDouble(),
            comment: r['comment'] as String? ?? '',
            date: DateTime.parse(r['created_at'] as String),
            service: '',
          );
        }).toList();
      }

      final reviewCount = reviews.length;
      final rating = reviewCount > 0
          ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviewCount
          : 0.0;

      state = state.copyWith(
        isLoading: false,
        name: '${profile['first_name']} ${profile['last_name']}',
        profession: skills.isNotEmpty ? skills.first : '',
        avatarUrl: profile['avatar_url'],
        description: workerProfile['bio'],
        workPhotos: workPhotos,
        skills: skills,
        additionalJobs: additionalJobs,
        customServices: customServices,
        availableTasks: availableTasks,
        availableDays: List<bool>.from(
          workerProfile['available_days'] ??
              [false, false, false, false, false, false, false],
        ),
        reviews: reviews,
        rating: rating,
        reviewCount: reviewCount,
      );
    } catch (e) {
      print('Error cargando datos: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addTask(String taskId, String taskName, double? price) async {
    try {
      if (state.additionalJobs.any((j) => j.name == taskName)) return;

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('worker_tasks').insert({
        'worker_id': userId,
        'task_id': taskId,
        'base_price': price,
      });

      state = state.copyWith(
        additionalJobs: [
          ...state.additionalJobs,
          AdditionalJob(name: taskName, basePrice: price),
        ],
      );
    } catch (e) {
      print('Error agregando task: $e');
    }
  }

  Future<void> removeTask(int index, String taskName) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('worker_tasks').delete().eq('worker_id', userId);

      final updated = List<AdditionalJob>.from(state.additionalJobs)
        ..removeAt(index);
      state = state.copyWith(additionalJobs: updated);
    } catch (e) {
      print('Error eliminando task: $e');
    }
  }

  Future<void> addCustomService(String serviceName, double? price) async {
    try {
      if (state.customServices.any((j) => j.name == serviceName)) return;

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('custom_services').insert({
        'worker_id': userId,
        'name': serviceName,
        'base_price': price,
      });

      state = state.copyWith(
        customServices: [
          ...state.customServices,
          AdditionalJob(name: serviceName, basePrice: price),
        ],
      );
    } catch (e) {
      print('Error agregando servicio personalizado: $e');
    }
  }

  Future<void> removeCustomService(int index, String serviceName) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('custom_services')
          .delete()
          .eq('worker_id', userId)
          .eq('name', serviceName);

      final updated = List<AdditionalJob>.from(state.customServices)
        ..removeAt(index);
      state = state.copyWith(customServices: updated);
    } catch (e) {
      print('Error eliminando servicio: $e');
    }
  }

  Future<void> pickAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) return;

      final fileExt = pickedFile.path.split('.').last;
      final filePath = '$userId/avatar.$fileExt';

      // 🔼 SUBIR A STORAGE
      await _supabase.storage
          .from('profiles')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      // 🔗 OBTENER URL
      final publicUrl = _supabase.storage
          .from('profiles')
          .getPublicUrl(filePath);

      // 💾 GUARDAR EN BD
      await _supabase
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      // 🧠 ACTUALIZAR ESTADO
      state = state.copyWith(avatarUrl: publicUrl, avatarPath: null);
    } catch (e) {
      print('Error subiendo avatar: $e');
    }
  }

  void toggleDay(int index) {
    final newDays = List<bool>.from(state.availableDays);
    newDays[index] = !newDays[index];
    state = state.copyWith(availableDays: newDays);
  }

  Future<void> deletePhoto(int index) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final photoUrl = state.workPhotos[index].url;

      // 🔍 extraer path desde URL
      final uri = Uri.parse(photoUrl);
      final filePath = uri.pathSegments
          .skipWhile((e) => e != 'work_photos')
          .skip(1)
          .join('/');

      // 🗑️ eliminar de storage
      await _supabase.storage.from('work_photos').remove([filePath]);

      // 🧠 actualizar lista
      final updatedPhotos = List<WorkPhoto>.from(state.workPhotos)
        ..removeAt(index);

      // 💾 actualizar DB
      final photoUrls = updatedPhotos.map((p) => p.url).toList();
      await _supabase
          .from('worker_profiles')
          .update({'work_photos': photoUrls})
          .eq('user_id', userId);

      // 🔄 estado
      state = state.copyWith(workPhotos: updatedPhotos);
    } catch (e) {
      print('Error eliminando foto: $e');
    }
  }

  Future<void> replacePhoto(int index) async {
    await deletePhoto(index);
    await addWorkPhoto();
  }

  Future<void> addWorkPhoto() async {
    if (state.workPhotos.length >= 3) return;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) return;

      final fileExt = pickedFile.path.split('.').last;
      final fileName = const Uuid().v4();

      final filePath = '$userId/$fileName.$fileExt';

      // 🔼 subir a storage
      await _supabase.storage.from('work_photos').upload(filePath, file);

      // 🔗 obtener url
      final publicUrl = _supabase.storage
          .from('work_photos')
          .getPublicUrl(filePath);

      // 🧠 actualizar lista local
      final updatedPhotos = [...state.workPhotos, WorkPhoto(url: publicUrl)];

      // 💾 guardar en DB
      final photoUrls = updatedPhotos.map((p) => p.url).toList();
      await _supabase
          .from('worker_profiles')
          .update({'work_photos': photoUrls})
          .eq('user_id', userId);

      // 🔄 actualizar estado
      state = state.copyWith(workPhotos: updatedPhotos);
    } catch (e) {
      print('Error subiendo foto: $e');
    }
  }

  List<Review> _getStaticReviews() {
    return [
      Review(
        id: '1',
        clientName: 'María García',
        clientAvatar: null,
        rating: 5,
        comment: 'Excelente trabajo, muy profesional y puntuales.',
        date: DateTime.now().subtract(const Duration(days: 2)),
        service: 'Limpieza',
      ),
      Review(
        id: '2',
        clientName: 'Juan Pérez',
        clientAvatar: null,
        rating: 4,
        comment: 'Buen servicio, puntuales y eficientes.',
        date: DateTime.now().subtract(const Duration(days: 5)),
        service: 'Pintura',
      ),
      Review(
        id: '3',
        clientName: 'Ana López',
        clientAvatar: null,
        rating: 5,
        comment: 'Muy satisfied with the service.',
        date: DateTime.now().subtract(const Duration(days: 10)),
        service: 'Carpintería',
      ),
      Review(
        id: '4',
        clientName: 'Carlos Martínez',
        clientAvatar: null,
        rating: 4,
        comment: 'Buena atención y resultados buenos.',
        date: DateTime.now().subtract(const Duration(days: 15)),
        service: 'Plomería',
      ),
    ];
  }
}
