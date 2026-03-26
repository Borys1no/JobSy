import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/core/widgets/top_background_layout.dart';
import '../worker_setup/worker_setup_controller.dart';
import '../worker_setup/services_provider.dart';
import '../worker_setup/widgets/photo_slot.dart';

class Step2Form extends ConsumerWidget {
  const Step2Form({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(workerSetupControllerProvider.notifier);
    final state = ref.watch(workerSetupControllerProvider);
    final popularServicesAsync = ref.watch(popularServicesProvider);

    return TopBackgroundLayout(
      title: 'Configuración del trabajador',
      child: GestureDetector(
        onTap: () {
          controller.setExpadingChip(null);
        }, // Cerrar expandible al tocar fuera
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
              'Paso 2 de 3',
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
                  'Tus servicios',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Profesión principal (readonly)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.primaryServiceName ?? 'Profesión no seleccionada',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Precio a acordar con el cliente',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Trabajos adicionales (opcional)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trabajos adicionales (opcional)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ofrece otros servicios que sabes hacer',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 16),

                      // Servicios populares
                      const Text(
                        'Servicios populares:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),

                      popularServicesAsync.when(
                        data: (popularServices) {
                          final visibleServices = popularServices
                              .take(6)
                              .toList();
                          final hasMore = popularServices.length > 6;

                          return Column(
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ...visibleServices.map((service) {
                                    final serviceId = service.id;
                                    final serviceName = service.name;
                                    final isExpanding =
                                        state.expandingChipId ==
                                        serviceId.toString();

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Chip
                                        GestureDetector(
                                          onTap: () =>
                                              controller.setExpadingChip(
                                                isExpanding
                                                    ? null
                                                    : serviceId.toString(),
                                              ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isExpanding
                                                  ? Colors.blue[50]
                                                  : Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isExpanding
                                                    ? Colors.blue
                                                    : Colors.grey[300]!,
                                              ),
                                            ),
                                            child: Text(
                                              serviceName,
                                              style: TextStyle(
                                                color: isExpanding
                                                    ? Colors.blue[700]
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Expandible con precio
                                        if (isExpanding) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            width: 250,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.blue,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withValues(
                                                    alpha: 0.1,
                                                  ),
                                                  spreadRadius: 1,
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  serviceName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                const Text(
                                                  '¿Cuánto cobras por este servicio?',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                TextField(
                                                  decoration:
                                                      const InputDecoration(
                                                        prefixText: '\$ ',
                                                        hintText: '0.00',
                                                        border:
                                                            OutlineInputBorder(),
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                      ),
                                                  keyboardType:
                                                      const TextInputType.numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                  onChanged: (value) {
                                                    controller
                                                        .updateServicePrice(
                                                          serviceId,
                                                          value,
                                                        );
                                                  },
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          controller
                                                              .setExpadingChip(
                                                                null,
                                                              ),
                                                      child: const Text(
                                                        'Cancelar',
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        // Aquí capturaríamos el precio del TextField
                                                        // Por simplicidad, usaremos un valor fijo para este ejemplo
                                                        final priceString =
                                                            state
                                                                .servicePrices[serviceId] ??
                                                            '';
                                                        final price =
                                                            double.tryParse(
                                                              priceString,
                                                            ) ??
                                                            0;

                                                        if (price <= 0) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                'Ingresa un precio válido',
                                                              ),
                                                            ),
                                                          );
                                                          return;
                                                        }
                                                        controller
                                                            .addPopularService(
                                                              serviceId:
                                                                  serviceId,
                                                              serviceName:
                                                                  serviceName,
                                                              price: price,
                                                            );
                                                        controller
                                                            .setExpadingChip(
                                                              null,
                                                            );
                                                      },
                                                      child: const Text(
                                                        'Agregar',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ],
                                    );
                                  }),

                                  if (hasMore)
                                    GestureDetector(
                                      onTap: () {
                                        // Aquí abriríamos modal con más servicios
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Próximamente: más servicios',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Ver más',
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.blue[700],
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Text('Error: $error'),
                      ),

                      const SizedBox(height: 16),

                      // Botón agregar servicio personalizado
                      if (!state.showCustomForm)
                        GestureDetector(
                          onTap: controller.toggleCustomForm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Agregar otro servicio personalizado',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Formulario de servicio personalizado
                      if (state.showCustomForm) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nuevo servicio personalizado',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Nombre del servicio',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: controller.updateCustomServiceName,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Precio base (desde \$)',
                                  border: OutlineInputBorder(),
                                  prefixText: '\$ ',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: controller.updateCustomServicePrice,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: controller.toggleCustomForm,
                                    child: const Text('Cancelar'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () =>
                                        controller.addCustomService(),
                                    child: const Text('Guardar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Lista de servicios adicionales seleccionados
                      if (state.additionalServices.isNotEmpty) ...[
                        const Text(
                          'Tus trabajos adicionales seleccionados:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        ...state.additionalServices.asMap().entries.map((
                          entry,
                        ) {
                          final index = entry.key;
                          final service = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '\$ ${service.basePrice.toStringAsFixed(2)} desde',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () =>
                                      controller.removeAdditionalService(index),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 8),
                      Text(
                        '💡 Los trabajos adicionales son opcionales. El precio base es referencial, el final se acuerda con el cliente.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Descripción breve
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Descripción breve',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(' *', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cuéntale a los clientes sobre tu experiencia',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        maxLines: 4,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText:
                              'Ej: "Soy técnico en plomería con 5 años de experiencia. He trabajado en residencias y edificios. Me especializo en..."',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                          counterText: '${state.description.length}/500',
                        ),
                        controller: TextEditingController(
                          text: state.description,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Fotos de trabajos realizados
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Fotos de trabajos realizados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(' *', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sube 3 fotos como ejemplo de tu trabajo',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(3, (index) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: index != 2 ? 8 : 0),
                            child: PhotoSlot(
                              index: index,
                              imagePath: state.workPhotos[index],
                              onTap: () => controller.pickWorkPhoto(index),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Botón Continuar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            final error = controller.validateStep2();
                            if (error != null) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(error)));
                              return;
                            }
                            final success = await controller.goToNextStep();
                            if (!success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    state.errorMessage ??
                                        'Completa todos los campos obligatorios',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Continuar',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    '* Campos obligatorios',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
