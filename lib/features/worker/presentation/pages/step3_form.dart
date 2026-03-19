import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => controller.goToPreviousStep(),
          ),
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
                        hintText: 'Ej: Urdesa, Norte, Centro',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                      ),
                      onChanged: controller.updateSector,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: state.isGettingLocation
                          ? null
                          : () => controller.getCurrentLocation(),
                      icon: state.isGettingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, size: 18),
                      label: Text(
                        state.isGettingLocation ? '...' : 'Ubicación',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
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
                onChanged: (_) => controller.toggleDay(1), // Lunes = 1
              ),
              _buildDaySwitch(
                label: 'Martes',
                value: state.availableTuesday,
                onChanged: (_) => controller.toggleDay(2), // Martes = 2
              ),
              _buildDaySwitch(
                label: 'Miércoles',
                value: state.availableWednesday,
                onChanged: (_) => controller.toggleDay(3), // Miércoles = 3
              ),
              _buildDaySwitch(
                label: 'Jueves',
                value: state.availableThursday,
                onChanged: (_) => controller.toggleDay(4), // Jueves = 4
              ),
              _buildDaySwitch(
                label: 'Viernes',
                value: state.availableFriday,
                onChanged: (_) => controller.toggleDay(5), // Viernes = 5
              ),
              _buildDaySwitch(
                label: 'Sábado',
                value: state.availableSaturday,
                onChanged: (_) => controller.toggleDay(6), // Sábado = 6
              ),
              _buildDaySwitch(
                label: 'Domingo',
                value: state.availableSunday,
                onChanged: (_) => controller.toggleDay(0), // Domingo = 0
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

                          final success = await controller.saveWorkerProfile();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Perfil completado con éxito!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Navigator.pushReplacement...
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
                      : const Text('Finalizar', style: TextStyle(fontSize: 16)),
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
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          // ✅ CORREGIDO: activeColor deprecado, usar activeThumbColor
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
