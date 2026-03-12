import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/top_background_layout.dart';
import 'package:jobsy/features/worker/presentation/worker_setup/worker_setup_controller.dart';
import 'package:jobsy/features/worker/presentation/worker_setup/services_provider.dart';

class Step1Form extends ConsumerWidget {
  const Step1Form({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(workerSetupControllerProvider.notifier);
    final state = ref.watch(workerSetupControllerProvider);
    final servicesAsync = ref.watch(allServicesProvider);

    return TopBackgroundLayout(
      title: 'Completar perfil',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paso 1 de 3',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Completar perfil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            //Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: state.avatarPath != null
                        ? FileImage(File(state.avatarPath!))
                        : null,
                    child: state.avatarPath == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => controller.pickImage(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            //Formulario
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombres',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: controller.updateFirstName,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Apellidos',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: controller.updateLastName,
            ),
            const SizedBox(height: 16),

            TextField(
              decoration: const InputDecoration(
                labelText: 'Cédula',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
                helperText: '10 dígitos sin guiones',
              ),
              keyboardType: TextInputType.number,
              maxLength: 10,
              onChanged: controller.updateNationalId,
            ),
            const SizedBox(height: 16),

            //Dropdpown de profesiones
            servicesAsync.when(
              data: (services) => DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Profesión',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                initialValue: state.selectedServiceId,
                items: services.map((service) {
                  return DropdownMenuItem<int>(
                    value: service['id'] as int,
                    child: Text(service['name'] as String),
                  );
                }).toList(),
                onChanged: controller.updateServiceId,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 24),

            //Boton continuar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final success = await controller.goToNextStep();
                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.errorMessage ?? 'Error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Continuar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
