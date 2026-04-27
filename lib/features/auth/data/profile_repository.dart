import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_providers.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  Future<bool> isProfileComplete(String userId) async {
    final profile = await getProfile(userId);
    if (profile == null) return false;

    final firstName = profile['first_name'] as String?;
    final lastName = profile['last_name'] as String?;
    final phone = profile['phone'] as String?;

    final identity = await _client
        .from('user_identity')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    final hasNationalId = identity != null && identity['national_id'] != null;

    return firstName != null &&
        firstName.isNotEmpty &&
        lastName != null &&
        lastName.isNotEmpty &&
        phone != null &&
        phone.isNotEmpty &&
        hasNationalId;
  }

  Future<void> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (phone != null) updates['phone'] = phone;
    if (address != null) updates['address'] = address;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', userId);
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return ProfileRepository(supabase);
});

final isProfileCompleteProvider = FutureProvider<bool>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return false;

  final repo = ref.read(profileRepositoryProvider);
  return repo.isProfileComplete(user.id);
});