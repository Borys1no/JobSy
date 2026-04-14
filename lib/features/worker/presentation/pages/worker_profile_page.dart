import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/core/theme/app_theme.dart';
import 'package:jobsy/features/worker/domain/worker_profile_state.dart';
import 'package:jobsy/features/worker/presentation/worker_profile/worker_profile_controller.dart';
import 'package:jobsy/features/worker/presentation/pages/worker_reviews_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:jobsy/features/onboarding/role_selection_page.dart';

class WorkerProfilePage extends ConsumerWidget {
  const WorkerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workerProfileControllerProvider);
    final controller = ref.read(workerProfileControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final borderColor = isDark ? const Color(0xFF3C3C3C) : Colors.grey[200]!;

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                size: 48,
                color: AppTheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'JobSy',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text(
          'Mi Perfil',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(
              context,
              state,
              controller,
              isDark,
              cardColor,
              textColor,
              subColor,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Información Personal', textColor),
            _buildInfoCard(
              [
                _buildInfoRow(
                  'Nombres',
                  '${state.firstName ?? ''} ${state.lastName ?? ''}',
                  editable: false,
                  textColor: textColor,
                  subColor: subColor,
                ),
                _buildInfoRow(
                  'Correo',
                  state.email ?? '',
                  editable: false,
                  textColor: textColor,
                  subColor: subColor,
                ),
                _buildInfoRow(
                  'Teléfono',
                  state.phone ?? 'No definido',
                  editable: true,
                  textColor: textColor,
                  subColor: subColor,
                  onTap: () => _showEditDialog(
                    context,
                    controller,
                    'phone',
                    'Teléfono',
                    state.phone ?? '',
                  ),
                ),
                _buildInfoRow(
                  'Dirección',
                  state.address ?? 'No definida',
                  editable: true,
                  textColor: textColor,
                  subColor: subColor,
                  onTap: () => _showEditDialog(
                    context,
                    controller,
                    'address',
                    'Dirección',
                    state.address ?? '',
                  ),
                ),
              ],
              cardColor,
              borderColor,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Perfil Profesional', textColor),
            _buildInfoCard(
              [
                _buildInfoRow(
                  'Profesión',
                  state.profession ?? 'No definida',
                  editable: false,
                  textColor: textColor,
                  subColor: subColor,
                ),
                _buildInfoRow(
                  'Biografía',
                  state.bio ?? 'Sin biografía',
                  editable: true,
                  textColor: textColor,
                  subColor: subColor,
                  onTap: () => _showEditDialog(
                    context,
                    controller,
                    'bio',
                    'Biografía',
                    state.bio ?? '',
                  ),
                ),
              ],
              cardColor,
              borderColor,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Idiomas', textColor),
            _buildLanguagesSection(
              context,
              state,
              controller,
              cardColor,
              textColor,
              subColor,
              borderColor,
              isDark,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Certificaciones', textColor),
            _buildCertificationsSection(
              context,
              state,
              controller,
              cardColor,
              textColor,
              subColor,
              borderColor,
              isDark,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Métodos de Pago', textColor),
            _buildInfoCard(
              [
                _buildInfoRow(
                  'Banco',
                  state.bankName.isEmpty ? 'No definido' : state.bankName,
                  editable: true,
                  textColor: textColor,
                  subColor: subColor,
                  onTap: () => _showBankDialog(context, controller),
                ),
                _buildInfoRow(
                  'Cuenta',
                  state.bankAccount.isEmpty
                      ? 'No definida'
                      : '****${state.bankAccount.substring(state.bankAccount.length - 4)}',
                  editable: false,
                  textColor: textColor,
                  subColor: subColor,
                ),
              ],
              cardColor,
              borderColor,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Privacidad', textColor),
            _buildPrivacySection(
              context,
              state,
              controller,
              cardColor,
              textColor,
              subColor,
              borderColor,
              isDark,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Reseñas', textColor),
            _buildReviewsButton(
              context,
              cardColor,
              textColor,
              subColor,
              borderColor,
              isDark,
            ),
            const SizedBox(height: 24),
            _buildDarkModeToggle(
              state,
              controller,
              cardColor,
              textColor,
              subColor,
              isDark,
            ),
            const SizedBox(height: 24),
            _buildLogoutButton(context, controller, cardColor, isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    WorkerProfileState state,
    WorkerProfileController controller,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subColor,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: controller.pickAvatar,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: isDark
                    ? const Color(0xFF3C3C3C)
                    : Colors.grey[200],
                backgroundImage: state.avatarUrl != null
                    ? NetworkImage(state.avatarUrl!) as ImageProvider
                    : null,
                child: state.avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: isDark ? Colors.grey[600] : Colors.grey,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: controller.pickAvatar,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
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
        const SizedBox(height: 12),
        Text(
          '${state.firstName ?? ''} ${state.lastName ?? ''}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          state.profession ?? '',
          style: TextStyle(fontSize: 16, color: subColor),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    List<Widget> children,
    Color cardColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool editable = false,
    VoidCallback? onTap,
    required Color textColor,
    required Color subColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: subColor)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 16, color: textColor)),
              ],
            ),
          ),
          if (editable)
            IconButton(
              icon: Icon(Icons.edit, size: 20, color: AppTheme.primary),
              onPressed: onTap,
            ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection(
    BuildContext context,
    WorkerProfileState state,
    WorkerProfileController controller,
    Color cardColor,
    Color textColor,
    Color subColor,
    Color borderColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          if (state.languages.isEmpty)
            Text('No hay idiomas agregados', style: TextStyle(color: subColor))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.languages
                  .map(
                    (lang) => Chip(
                      label: Text(lang, style: TextStyle(color: textColor)),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => controller.removeLanguage(lang),
                      backgroundColor: isDark
                          ? const Color(0xFF2C2C2C)
                          : Colors.grey[100],
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showAddLanguageDialog(context, controller),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Idioma'),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsSection(
    BuildContext context,
    WorkerProfileState state,
    WorkerProfileController controller,
    Color cardColor,
    Color textColor,
    Color subColor,
    Color borderColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          if (state.certifications.isEmpty)
            Text(
              'No hay certificaciones agregadas',
              style: TextStyle(color: subColor),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.certifications
                  .map(
                    (cert) => Chip(
                      label: Text(cert, style: TextStyle(color: textColor)),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => controller.removeCertification(cert),
                      backgroundColor: isDark
                          ? const Color(0xFF2C2C2C)
                          : Colors.grey[100],
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showAddCertificationDialog(context, controller),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Certificación'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(
    BuildContext context,
    WorkerProfileState state,
    WorkerProfileController controller,
    Color cardColor,
    Color textColor,
    Color subColor,
    Color borderColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildPrivacyOption(
            context,
            'Público',
            'Todos pueden ver tu perfil',
            state.privacySetting == 'public',
            () => controller.updatePrivacy('public'),
            textColor,
            subColor,
          ),
          _buildPrivacyOption(
            context,
            'Solo clientes',
            'Solo clientes pueden ver',
            state.privacySetting == 'clients',
            () => controller.updatePrivacy('clients'),
            textColor,
            subColor,
          ),
          _buildPrivacyOption(
            context,
            'Privado',
            'Solo tú puedes ver',
            state.privacySetting == 'private',
            () => controller.updatePrivacy('private'),
            textColor,
            subColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption(
    BuildContext context,
    String title,
    String subtitle,
    bool isSelected,
    VoidCallback onTap,
    Color textColor,
    Color subColor,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subColor)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppTheme.primary)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildReviewsButton(
    BuildContext context,
    Color cardColor,
    Color textColor,
    Color subColor,
    Color borderColor,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        leading: const Icon(Icons.star_outline, color: AppTheme.primary),
        title: Text('Ver mis reseñas', style: TextStyle(color: textColor)),
        trailing: Icon(Icons.chevron_right, color: subColor),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WorkerReviewsPage()),
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle(
    WorkerProfileState state,
    WorkerProfileController controller,
    Color cardColor,
    Color textColor,
    Color subColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.dark_mode_outlined, color: AppTheme.primary),
              const SizedBox(width: 12),
              Text('Modo oscuro', style: TextStyle(color: textColor)),
            ],
          ),
          Switch(
            value: state.isDarkMode,
            onChanged: (_) => controller.toggleDarkMode(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    WorkerProfileController controller,
    Color cardColor,
    bool isDark,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context, controller),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WorkerProfileController controller,
    String field,
    String label,
    String currentValue,
  ) {
    final textController = TextEditingController(text: currentValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Editar $label',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: isDark ? const Color(0xFF2C2C2C) : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = textController.text.trim();
              switch (field) {
                case 'phone':
                  controller.updatePhone(value);
                  break;
                case 'address':
                  controller.updateAddress(value);
                  break;
                case 'bio':
                  controller.updateBio(value);
                  break;
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showBankDialog(
    BuildContext context,
    WorkerProfileController controller,
  ) {
    final bankNameController = TextEditingController();
    final accountController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Cuenta Bancaria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bankNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del banco',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: accountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de cuenta',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateBankAccount(
                bankNameController.text.trim(),
                accountController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAddLanguageDialog(
    BuildContext context,
    WorkerProfileController controller,
  ) {
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Idioma'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Idioma',
            hintText: 'Ej: Inglés',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty)
                controller.addLanguage(textController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showAddCertificationDialog(
    BuildContext context,
    WorkerProfileController controller,
  ) {
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Certificación'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Certificación',
            hintText: 'Ej: ISO 9001',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty)
                controller.addCertification(textController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(
    BuildContext context,
    WorkerProfileController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              await controller.logout();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const RoleSelectionPage(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
