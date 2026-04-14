import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/core/theme/app_theme.dart';
import 'package:jobsy/features/worker/presentation/pages/worker_onboarding_page.dart';
import 'package:jobsy/features/worker/presentation/pages/worker_home_page.dart';
import 'package:jobsy/features/auth/presentation/auth_controller.dart';
import 'package:jobsy/features/auth/presentation/register_page.dart';
import 'package:jobsy/features/client/presentation/pages/client_onboarding_page.dart';
import 'package:jobsy/features/client/presentation/pages/client_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String role;
  const LoginPage({super.key, required this.role});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final inputFillColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final inputBorderColor = isDark
        ? const Color(0xFF3C3C3C)
        : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Icon(Icons.construction, size: 80, color: AppTheme.primary),
                const SizedBox(height: 16),
                Text(
                  'JobSy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bienvenido de nuevo',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: subColor),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: subColor),
                    prefixIcon: Icon(Icons.email_outlined, color: subColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: inputBorderColor),
                    ),
                    filled: true,
                    fillColor: inputFillColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: inputBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Ingresa tu correo electrónico';
                    if (!value.contains('@')) return 'Ingresa un correo válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: subColor),
                    prefixIcon: Icon(Icons.lock_outlined, color: subColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: subColor,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: inputBorderColor),
                    ),
                    filled: true,
                    fillColor: inputFillColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: inputBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Ingresa tu contraseña';
                    if (value.length < 6)
                      return 'La contraseña debe tener al menos 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(color: subColor),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegisterPage(role: widget.role),
                        ),
                      ),
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .login(_emailCtrl.text, _passCtrl.text);

      if (!mounted) return;

      if (result.role == "worker") {
        if (result.hasWorkerProfile) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WorkerHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WorkerOnboardingPage()),
          );
        }
      } else if (result.role == "client") {
        final prefs = await SharedPreferences.getInstance();
        final hasSeenOnboarding =
            prefs.getBool("hasSeenClientOnboarding") ?? false;
        if (hasSeenOnboarding) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ClientHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ClientOnboardingPage()),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      String message = 'Ocurrió un error. Verifica tus credenciales.';

      final errorLower = e.toString().toLowerCase();
      if (errorLower.contains('invalid') ||
          errorLower.contains('credentials') ||
          errorLower.contains('login')) {
        message = 'Correo o contraseña incorrectos';
      } else if (errorLower.contains('network') ||
          errorLower.contains('connection')) {
        message = 'Error de conexión. Verifica tu internet.';
      } else if (errorLower.contains('confirm') ||
          errorLower.contains('email')) {
        message = 'Debes confirmar tu correo antes de ingresar.';
      } else if (errorLower.contains('user') &&
          errorLower.contains('not found')) {
        message = 'Usuario no encontrado';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
