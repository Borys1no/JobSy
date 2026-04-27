import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/core/theme/app_theme.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:jobsy/features/client/presentation/chat/chat_page.dart';

class WorkerNotificationsPage extends ConsumerStatefulWidget {
  const WorkerNotificationsPage({super.key});

  @override
  ConsumerState<WorkerNotificationsPage> createState() => _WorkerNotificationsPageState();
}

class _WorkerNotificationsPageState extends ConsumerState<WorkerNotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadNotifications);
  }

  Future<void> _loadNotifications() async {
    final supabase = ref.read(supabaseProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await supabase.from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);
      
      if (mounted) {
        setState(() {
          _notifications = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text('Notificaciones', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState(subtitleColor)
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      return _buildNotificationItem(context, notif, cardColor, textColor, subtitleColor, isDark);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(Color subtitleColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(_hasError ? 'Error al cargar notificaciones' : 'No tienes notificaciones aún', style: TextStyle(fontSize: 18, color: subtitleColor)),
          const SizedBox(height: 8),
          if (_hasError) ElevatedButton(onPressed: _loadNotifications, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> notif, Color cardColor, Color textColor, Color subtitleColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: notif['is_read'] == false ? Border.all(color: AppTheme.primary, width: 2) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          child: Icon(_getNotificationIcon(notif['type'] as String?), color: AppTheme.primary),
        ),
        title: Text(notif['title'] as String? ?? 'Notificación', style: TextStyle(fontWeight: notif['is_read'] == false ? FontWeight.bold : FontWeight.normal, color: textColor)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notif['body'] as String? ?? '', style: TextStyle(color: subtitleColor, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(_formatTime(DateTime.parse(notif['created_at'] as String)), style: TextStyle(fontSize: 11, color: subtitleColor)),
          ],
        ),
        onTap: () => _onNotificationTap(context, notif),
      ),
    );
  }

  void _onNotificationTap(BuildContext context, Map<String, dynamic> notif) async {
    final supabase = ref.read(supabaseProvider);
    if (notif['is_read'] == false) {
      await supabase.from('notifications').update({'is_read': true}).eq('id', notif['id']);
      _loadNotifications();
    }
    if (notif['type'] == 'message' || notif['type'] == 'chat') {
      final chatId = notif['chat_id'] as String?;
      if (chatId != null) Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(chatId: chatId)));
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'message': return Icons.chat_bubble;
      case 'chat': return Icons.chat_bubble;
      case 'job': return Icons.work;
      case 'review': return Icons.star;
      default: return Icons.notifications;
    }
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }
}