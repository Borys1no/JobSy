import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/core/theme/app_theme.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:jobsy/features/auth/data/profile_repository.dart';
import 'package:jobsy/features/auth/presentation/login_page.dart';
import 'package:jobsy/features/client/presentation/pages/complete_client_profile_page.dart';

final clientProfileProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return null;

  final profile = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  if (profile == null) return null;

  return {...profile, 'email': user.email};
});

class ClientProfilePage extends ConsumerStatefulWidget {
  const ClientProfilePage({super.key});

  @override
  ConsumerState<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends ConsumerState<ClientProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(clientProfileProvider);
    final isProfileCompleteAsync = ref.watch(isProfileCompleteProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    final isProfileComplete = isProfileCompleteAsync.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.clientPrimary,
        foregroundColor: Colors.white,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (!isProfileComplete)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.amber[700],
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Completa tu perfil para una mejor experiencia',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CompleteClientProfilePage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.amber[900],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Completar'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: subtitleColor),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      style: TextStyle(color: subtitleColor),
                    ),
                  ],
                ),
              ),
              data: (profile) {
                if (profile == null) {
                  return Center(
                    child: Text(
                      'No se encontró el perfil',
                      style: TextStyle(color: subtitleColor),
                    ),
                  );
                }

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      color: AppTheme.clientPrimary,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: profile['avatar_url'] != null
                                ? NetworkImage(profile['avatar_url'] as String)
                                : null,
                            child: profile['avatar_url'] == null
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppTheme.clientPrimary,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              profile['email'] as String? ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: AppTheme.clientPrimary,
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        tabs: const [
                          Tab(text: 'Configuración'),
                          Tab(text: 'Pagos'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSettingsTab(
                            cardColor,
                            textColor,
                            subtitleColor,
                            profile,
                          ),
                          _buildPaymentsTab(
                            cardColor,
                            textColor,
                            subtitleColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(
    Color cardColor,
    Color textColor,
    Color subtitleColor,
    Map<String, dynamic> profile,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Datos del perfil', textColor),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildProfileTile(
                  icon: Icons.person_outline,
                  label: 'Nombre',
                  value:
                      '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}',
                  subtitleColor: subtitleColor,
                  textColor: textColor,
                  canEdit: false,
                ),
                const Divider(height: 1),
                _buildProfileTile(
                  icon: Icons.email_outlined,
                  label: 'Correo electrónico',
                  value: profile['email'] as String? ?? '',
                  subtitleColor: subtitleColor,
                  textColor: textColor,
                  canEdit: false,
                ),
                const Divider(height: 1),
                _buildProfileTile(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  value: profile['phone'] as String? ?? 'No configurado',
                  subtitleColor: subtitleColor,
                  textColor: textColor,
                  canEdit: true,
                  onTap: () => _showEditDialog(
                    'Teléfono',
                    'phone',
                    profile['phone'] as String? ?? '',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Preferencias', textColor),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppTheme.clientPrimary,
                  ),
                  title: Text(
                    'Modo oscuro',
                    style: TextStyle(color: textColor),
                  ),
                  subtitle: Text(
                    _isDarkMode ? 'Activado' : 'Desactivado',
                    style: TextStyle(color: subtitleColor),
                  ),
                  trailing: Switch(
                    value: _isDarkMode,
                    activeTrackColor: AppTheme.clientPrimary,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Soporte', textColor),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.help_outline,
                    color: AppTheme.clientPrimary,
                  ),
                  title: Text(
                    'Preguntas frecuentes',
                    style: TextStyle(color: textColor),
                  ),
                  trailing: Icon(Icons.chevron_right, color: subtitleColor),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.chat_outlined,
                    color: AppTheme.clientPrimary,
                  ),
                  title: Text(
                    'contactar soporte',
                    style: TextStyle(color: textColor),
                  ),
                  trailing: Icon(Icons.chevron_right, color: subtitleColor),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPaymentsTab(
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Métodos de pago', textColor),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.clientPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.credit_card, color: AppTheme.clientPrimary),
              ),
              title: Text(
                'Agregar método de pago',
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                'Visa, Mastercard, etc.',
                style: TextStyle(color: subtitleColor),
              ),
              trailing: Icon(Icons.add, color: AppTheme.clientPrimary),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Historial de pagos', textColor),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 50, color: subtitleColor),
                const SizedBox(height: 12),
                Text(
                  'No hay pagos realizados',
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu historial de pagos aparecerá aquí',
                  style: TextStyle(color: subtitleColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String label,
    required String value,
    required Color subtitleColor,
    required Color textColor,
    required bool canEdit,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.clientPrimary),
      title: Text(label, style: TextStyle(color: textColor)),
      subtitle: Text(value, style: TextStyle(color: subtitleColor)),
      trailing: canEdit
          ? Icon(Icons.edit, color: AppTheme.clientPrimary, size: 20)
          : null,
      onTap: onTap,
    );
  }

  void _showEditDialog(String fieldName, String fieldKey, String currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $fieldName'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: fieldName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final supabase = ref.read(supabaseProvider);
              final user = supabase.auth.currentUser;

              if (user != null) {
                await supabase
                    .from('profiles')
                    .update({fieldKey: controller.text})
                    .eq('id', user.id);

                ref.invalidate(clientProfileProvider);
              }

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$fieldName actualizado')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.clientPrimary,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final supabase = ref.read(supabaseProvider);
              await supabase.auth.signOut();

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(role: 'client'),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
