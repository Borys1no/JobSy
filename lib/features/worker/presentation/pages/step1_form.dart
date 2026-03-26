import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/features/worker/presentation/pages/step2_form.dart';
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
    final error = state.errorMessage;
    final isFormValid =
        state.firstName.isNotEmpty &&
        state.lastName.isNotEmpty &&
        state.nationalId.length == 10 &&
        state.selectedServiceId != null;

    return TopBackgroundLayout(
      title: 'Completar perfil',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
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
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
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
                controller: TextEditingController(text: state.firstName),
                onChanged: controller.updateFirstName,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                controller: TextEditingController(text: state.lastName),
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
                controller: TextEditingController(text: state.nationalId),
                onChanged: controller.updateNationalId,
              ),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  helperText: 'Ej: 0991234567',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                onChanged: controller.updatePhone,
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
                  initialValue:
                      services.any((s) => s.id == state.selectedServiceId)
                      ? state.selectedServiceId
                      : null,
                  items: services.map((service) {
                    return DropdownMenuItem<int>(
                      value: service.id,
                      child: Text(service.name),
                    );
                  }).toList(),
                  onChanged: (id) {
                    final selected = services.where((s) => s.id == id);

                    if (selected.isNotEmpty) {
                      final service = selected.first;

                      controller.updateService(
                        id: service.id,
                        name: service.name,
                      );
                    }
                  },
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
                  onPressed: state.isLoading || !isFormValid
                      ? null
                      : () async {
                          final success = await controller.goToNextStep();
                          if (!context.mounted) return;
                          if (success) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Step2Form(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error ?? 'Error'),
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
      ),
    );
  }
}
