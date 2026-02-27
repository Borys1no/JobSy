import 'package:flutter/material.dart';

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/complete_profile.png"),
            const SizedBox(height: 30),
            const Text(
              "¡Completa tu perfil!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Text(
              "Por favor completa tu perfil para poder ser visualizado por tus potenciales clientes",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // aquí luego irás a editar perfil
              },
              child: const Text("Continuar"),
            ),
          ],
        ),
      ),
    );
  }
}
