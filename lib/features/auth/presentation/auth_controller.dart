import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import '../data/auth_repository.dart';

class LoginResult {
  final String role;
  final bool hasWorkerProfile;

  LoginResult({required this.role, required this.hasWorkerProfile});
}

class AuthController extends StateNotifier<bool> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(false);

  Future<LoginResult> login(String email, String password) async {
    state = true;
    try {
      final response = await _repository.login(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw Exception("Error en login");
      }
      if (user.emailConfirmedAt == null) {
        throw Exception("Debes confirmar tu correo antes de ingresar.");
      }

      //Obtener el role desde metadata
      String role = user.userMetadata?['role']?.toString() ?? 'worker';
      if (role.isEmpty) {
        throw Exception("No se encontro el rol del usuario.");
      }

      final profile = await _repository.getProfile(user.id);
      if (profile == null) {
        await _repository.createProfile(id: user.id, role: role);
      }

      // Verificar si el worker tiene perfil completo
      bool hasWorkerProfile = false;
      if (role == 'worker') {
        hasWorkerProfile = await _repository.hasWorkerProfile(user.id);
      }

      return LoginResult(role: role, hasWorkerProfile: hasWorkerProfile);
    } finally {
      state = false;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String role,
  }) async {
    state = true;

    try {
      final response = await _repository.register(
        email: email,
        password: password,
        role: role,
      );
      final user = response.user;
      if (user == null) {
        throw Exception("No se pudo registrar el usuario.");
      }
    } finally {
      state = false;
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  final repo = ref.read(authRepositoryProvider);
  return AuthController(repo);
});
