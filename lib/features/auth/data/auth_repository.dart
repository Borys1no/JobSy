import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception("No se pudo crear el usuario");
    }
    await _client.from('profiles').insert({
      'id': user.id,
      'role': role,
      'phone': 'null',
      'phone_verified': false,
    });
    return response;
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
