import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/presentation/login_page.dart';
import '../../theme/theme_provider.dart';

class RoleSelectionPage extends ConsumerWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenido a JobSy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            //cliente
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(role: 'client'),
                  ),
                );
              },
              child: const Text('Estoy buscando un profesional'),
            ),
            const SizedBox(height: 20),

            //Profesional
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(role: 'worker'),
                  ),
                );
              },
              child: const Text('Soy un profesional'),
            ),
            const SizedBox(height: 40),

            //Dark mode toggle
            SwitchListTile(
              title: const Text('Cambiar a modo oscuro'),
              value: isDark,
              onChanged: (value) {
                ref.read(themeProvider.notifier).state = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
