import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import '../data/auth_repository.dart';

class AuthController extends StateNotifier<bool> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(false);

  Future<void> login(String email, String password) async {
    state = true;
    try {
      await _repository.login(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<void> register(String email, String password) async {
    state = true;
    try {
      await _repository.register(email: email, password: password);
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
