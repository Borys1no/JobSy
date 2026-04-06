import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/features/worker/presentation/pages/loading_screen.dart';
import 'package:jobsy/features/worker/presentation/pages/succes_screen.dart';
import '../../../../core/widgets/top_background_layout.dart';
import '../worker_setup/worker_setup_controller.dart';

class Step3Form extends ConsumerWidget {
  const Step3Form({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(workerSetupControllerProvider.notifier);
    final state = ref.watch(workerSetupControllerProvider);

    return TopBackgroundLayout(
      title: 'Registra tu direccion',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Paso 3 de 3',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubicación y disponibilidad',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Cuéntanos dónde trabajas y tu disponibilidad',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Ciudad (no editable)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_city, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ciudad',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          state.city,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sector + Botón ubicación
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Sector',
                        hintText: 'Ej: Urdesa, Alborada, Samanes ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                      ),
                      onChanged: controller.updateSector,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 16),

              // Dirección
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  hintText: 'Ej: Av. Principal y Calle Secundaria, casa #123',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 2,
                onChanged: controller.updateAddress,
              ),
              const SizedBox(height: 32),
              Text(
                '📍 Por ahora esta app solo está disponible en Guayaquil. Próximamente más ciudades.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),

              // Disponibilidad
              const Text(
                'Disponibilidad',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona los días que puedes trabajar',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 16),

              // ✅ CORREGIDO: Mapeo de días a int para toggleDay
              _buildDaySwitch(
                label: 'Lunes',
                value: state.availableMonday,
                onTap: () => controller.toggleDay(1), // Lunes = 1
              ),
              _buildDaySwitch(
                label: 'Martes',
                value: state.availableTuesday,
                onTap: () => controller.toggleDay(2), // Martes = 2
              ),
              _buildDaySwitch(
                label: 'Miércoles',
                value: state.availableWednesday,
                onTap: () => controller.toggleDay(3), // Miércoles = 3
              ),
              _buildDaySwitch(
                label: 'Jueves',
                value: state.availableThursday,
                onTap: () => controller.toggleDay(4), // Jueves = 4
              ),
              _buildDaySwitch(
                label: 'Viernes',
                value: state.availableFriday,
                onTap: () => controller.toggleDay(5), // Viernes = 5
              ),
              _buildDaySwitch(
                label: 'Sábado',
                value: state.availableSaturday,
                onTap: () => controller.toggleDay(6), // Sábado = 6
              ),
              _buildDaySwitch(
                label: 'Domingo',
                value: state.availableSunday,
                onTap: () => controller.toggleDay(0), // Domingo = 0
              ),

              const Divider(height: 32),

              // Disponibilidad emergencia
              SwitchListTile(
                title: const Text(
                  'Disponibilidad 24/7',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '¿Estás disponible para emergencias?',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                value: state.availableEmergency,
                onChanged: (_) => controller.toggleEmergency(),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: state.availableEmergency
                        ? Colors.green[100]
                        : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emergency,
                    color: state.availableEmergency
                        ? Colors.green[700]
                        : Colors.grey[600],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botón Finalizar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          final error = controller.validateStep3();
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  const LoadingScreen(),
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );

                          final success = await controller.saveWorkerProfile();

                          if (success && context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const SuccessScreen(),
                                transitionsBuilder: (_, animation, __, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          } else if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  state.errorMessage ?? 'Error al guardar',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: state.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Finalizar registro',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySwitch({
    required String label,
    required bool value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: value ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? Colors.blue : Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.circle_outlined,
            color: value ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                color: value ? Colors.blue[700] : Colors.black87,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) => onTap(),
            activeThumbColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
