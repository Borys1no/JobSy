import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jobsy/core/config/supabase_client.dart';
import 'package:jobsy/features/worker/domain/worker_home_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

part 'worker_home_controller.g.dart';

@riverpod
class WorkerHomeController extends _$WorkerHomeController {
  SupabaseClient get _supabase => ref.read(supabaseClientProvider);

  @override
  WorkerHomeState build() {
    loadWorkerData();
    return WorkerHomeState.initial();
  }

  Future<void> loadWorkerData() async {
    try {
      state = state.copyWith(isLoading: true);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final workerProfile = await _supabase
          .from('worker_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      final services = await _supabase
          .from('worker_services')
          .select('service_id, services(name)')
          .eq('worker_id', userId);

      final skills = services
          .map<String>((s) => s['services']['name'] as String)
          .toList();

      state = state.copyWith(
        isLoading: false,
        name: '${profile['first_name']} ${profile['last_name']}',
        profession: skills.isNotEmpty ? skills.first : '',
        avatarUrl: profile['avatar_url'],
        description: workerProfile['bio'],
        workPhotos: List<String>.from(workerProfile['work_photos'] ?? []),
        skills: skills,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
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

      final photoUrl = state.workPhotos[index];

      // 🔍 extraer path desde URL
      final uri = Uri.parse(photoUrl);
      final filePath = uri.pathSegments
          .skipWhile((e) => e != 'work_photos')
          .skip(1)
          .join('/');

      // 🗑️ eliminar de storage
      await _supabase.storage.from('work_photos').remove([filePath]);

      // 🧠 actualizar lista
      final updatedPhotos = List<String>.from(state.workPhotos)
        ..removeAt(index);

      // 💾 actualizar DB
      await _supabase
          .from('worker_profiles')
          .update({'work_photos': updatedPhotos})
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
      final updatedPhotos = [...state.workPhotos, publicUrl];

      // 💾 guardar en DB
      await _supabase
          .from('worker_profiles')
          .update({'work_photos': updatedPhotos})
          .eq('user_id', userId);

      // 🔄 actualizar estado
      state = state.copyWith(workPhotos: updatedPhotos);
    } catch (e) {
      print('Error subiendo foto: $e');
    }
  }
}
