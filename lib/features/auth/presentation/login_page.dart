import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/features/worker/presentation/pages/worker_onboarding_page.dart';
import 'package:jobsy/features/worker/presentation/pages/worker_home_page.dart';
import 'auth_controller.dart';
import 'register_page.dart';

class LoginPage extends ConsumerWidget {
  final String role;
  const LoginPage({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(authControllerProvider);
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      try {
                        final result = await ref
                            .read(authControllerProvider.notifier)
                            .login(emailCtrl.text, passCtrl.text);
                        if (!context.mounted) return;

                        if (result.role == "worker") {
                          if (result.hasWorkerProfile) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WorkerHomePage(),
                              ),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WorkerOnboardingPage(),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage(role: role)),
                );
              },
              child: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
