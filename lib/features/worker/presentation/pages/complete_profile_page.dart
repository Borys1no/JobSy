import 'package:flutter/material.dart';
import 'package:jobsy/core/widgets/blob_image.dart';
import 'package:jobsy/features/worker/presentation/pages/step1_form.dart';

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
            BlobImage(
              imagePath: "assets/images/worker/worker_alert.png",
              height: 300,
              variant: 1,
            ),

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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Step1Form()),
                );
              },
              child: const Text("Continuar"),
            ),
          ],
        ),
      ),
    );
  }
}
