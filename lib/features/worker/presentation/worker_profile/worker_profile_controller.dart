import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:jobsy/features/worker/domain/worker_profile_state.dart';
import 'package:jobsy/theme/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

part 'worker_profile_controller.g.dart';

@riverpod
class WorkerProfileController extends _$WorkerProfileController {
  SupabaseClient get _supabase => ref.read(supabaseProvider);

  @override
  WorkerProfileState build() {
    Future.microtask(() => loadProfile());
    return WorkerProfileState.initial();
  }

  Future<void> loadProfile() async {
    try {
      state = state.copyWith(isLoading: true);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

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
          .select('services(name)')
          .eq('worker_id', userId)
          .eq('service_type', 'primary');

      final profession = services.isNotEmpty
          ? services.first['services']['name'] as String?
          : null;

      state = state.copyWith(
        isLoading: false,
        firstName: profile['first_name'] as String?,
        lastName: profile['last_name'] as String?,
        email: _supabase.auth.currentUser?.email,
        phone: profile['phone'] as String?,
        avatarUrl: profile['avatar_url'] as String?,
        address: workerProfile['address'] as String?,
        bio: workerProfile['bio'] as String?,
        profession: profession,
        languages: (workerProfile['languages'] as List?)?.cast<String>() ?? [],
        certifications:
            (workerProfile['certifications'] as List?)?.cast<String>() ?? [],
        bankAccount: workerProfile['bank_account'] as String? ?? '',
        bankName: workerProfile['bank_name'] as String? ?? '',
        privacySetting: workerProfile['privacy_setting'] as String? ?? 'public',
      );
    } catch (e) {
      print('Error cargando perfil: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updatePhone(String phone) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('profiles')
          .update({'phone': phone})
          .eq('id', userId);

      state = state.copyWith(phone: phone);
    } catch (e) {
      print('Error actualizando teléfono: $e');
    }
  }

  Future<void> updateAddress(String address) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('worker_profiles')
          .update({'address': address})
          .eq('user_id', userId);

      state = state.copyWith(address: address);
    } catch (e) {
      print('Error actualizando dirección: $e');
    }
  }

  Future<void> updateBio(String bio) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('worker_profiles')
          .update({'bio': bio})
          .eq('user_id', userId);

      state = state.copyWith(bio: bio);
    } catch (e) {
      print('Error actualizando biografía: $e');
    }
  }

  Future<void> updateBankAccount(String bankName, String accountNumber) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('worker_profiles')
          .update({'bank_name': bankName, 'bank_account': accountNumber})
          .eq('user_id', userId);

      state = state.copyWith(bankName: bankName, bankAccount: accountNumber);
    } catch (e) {
      print('Error actualizando cuenta bancaria: $e');
    }
  }

  Future<void> addLanguage(String language) async {
    try {
      if (state.languages.contains(language)) return;

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final newLanguages = [...state.languages, language];

      await _supabase
          .from('worker_profiles')
          .update({'languages': newLanguages})
          .eq('user_id', userId);

      state = state.copyWith(languages: newLanguages);
    } catch (e) {
      print('Error agregando idioma: $e');
    }
  }

  Future<void> removeLanguage(String language) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final newLanguages = state.languages.where((l) => l != language).toList();

      await _supabase
          .from('worker_profiles')
          .update({'languages': newLanguages})
          .eq('user_id', userId);

      state = state.copyWith(languages: newLanguages);
    } catch (e) {
      print('Error eliminando idioma: $e');
    }
  }

  Future<void> addCertification(String certification) async {
    try {
      if (state.certifications.contains(certification)) return;

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final newCertifications = [...state.certifications, certification];

      await _supabase
          .from('worker_profiles')
          .update({'certifications': newCertifications})
          .eq('user_id', userId);

      state = state.copyWith(certifications: newCertifications);
    } catch (e) {
      print('Error agregando certificación: $e');
    }
  }

  Future<void> removeCertification(String certification) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final newCertifications = state.certifications
          .where((c) => c != certification)
          .toList();

      await _supabase
          .from('worker_profiles')
          .update({'certifications': newCertifications})
          .eq('user_id', userId);

      state = state.copyWith(certifications: newCertifications);
    } catch (e) {
      print('Error eliminando certificación: $e');
    }
  }

  Future<void> updatePrivacy(String setting) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('worker_profiles')
          .update({'privacy_setting': setting})
          .eq('user_id', userId);

      state = state.copyWith(privacySetting: setting);
    } catch (e) {
      print('Error actualizando privacidad: $e');
    }
  }

  void toggleDarkMode() {
    final newValue = !state.isDarkMode;
    ref.read(themeProvider.notifier).state = newValue;
    state = state.copyWith(isDarkMode: newValue);
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

      await _supabase.storage
          .from('profiles')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      final publicUrl = _supabase.storage
          .from('profiles')
          .getPublicUrl(filePath);

      await _supabase
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      state = state.copyWith(avatarUrl: publicUrl);
    } catch (e) {
      print('Error subiendo avatar: $e');
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
