import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/core/config/supabase_client.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:jobsy/features/client/domain/chat_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'worker_chat_controller.g.dart';

@riverpod
class WorkerChatController extends _$WorkerChatController {
  SupabaseClient get _supabase => ref.read(supabaseProvider);

  @override
  ChatListState build() {
    Future.microtask(() => loadChats());
    return ChatListState.initial();
  }

  Future<void> loadChats() async {
    try {
      state = state.copyWith(isLoading: true);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final chatsData = await _supabase
          .from('chats')
          .select()
          .or('client_id.eq.$userId,worker_id.eq.$userId')
          .order('created_at', ascending: false);

      final List<ChatConversation> conversations = [];

      for (final chat in chatsData) {
        final isWorker = chat['worker_id'] == userId;
        final otherId = isWorker ? chat['client_id'] : chat['worker_id'];

        final profileData = await _supabase
            .from('profiles')
            .select('first_name, last_name, avatar_url')
            .eq('id', otherId)
            .maybeSingle();

        if (profileData == null) continue;

        final name = '${profileData['first_name'] ?? ''} ${profileData['last_name'] ?? ''}'.trim();
        final avatar = profileData['avatar_url'] as String?;

        final messagesData = await _supabase
            .from('messages')
            .select('content, created_at')
            .eq('chat_id', chat['id'])
            .order('created_at', ascending: false)
            .limit(1);

        String? lastMessage;
        DateTime? lastMessageAt;
        if (messagesData.isNotEmpty) {
          lastMessage = messagesData.first['content'] as String?;
          lastMessageAt = DateTime.tryParse(messagesData.first['created_at'] as String? ?? '');
        }

        final unreadCount = await _supabase
            .from('messages')
            .count()
            .eq('chat_id', chat['id'])
            .neq('sender_id', userId);

        final hasUnread = await _supabase
            .from('messages')
            .select('id')
            .eq('chat_id', chat['id'])
            .eq('is_read', false)
            .neq('sender_id', userId)
            .limit(1)
            .then((value) => value.isNotEmpty);

        if (isWorker) {
          conversations.add(ChatConversation(
            id: chat['id'] as String,
            chatId: chat['id'] as String,
            clientId: chat['client_id'] as String,
            workerId: userId,
            clientName: name,
            workerName: 'Tú',
            clientAvatar: avatar,
            lastMessage: lastMessage,
            lastMessageAt: lastMessageAt,
            hasUnreadMessages: hasUnread,
          ));
        } else {
          final workerData = await _supabase
              .from('profiles')
              .select('first_name, last_name, avatar_url')
              .eq('id', chat['worker_id'])
              .maybeSingle();

          conversations.add(ChatConversation(
            id: chat['id'] as String,
            chatId: chat['id'] as String,
            clientId: userId,
            workerId: chat['worker_id'] as String,
            clientName: 'Tú',
            workerName: name,
            workerAvatar: avatar,
            lastMessage: lastMessage,
            lastMessageAt: lastMessageAt,
            hasUnreadMessages: hasUnread,
          ));
        }
      }

      state = state.copyWith(
        isLoading: false,
        conversations: conversations,
      );
    } catch (e) {
      print('Error loading worker chats: $e');
      state = state.copyWith(isLoading: false);
    }
  }
}

@riverpod
class WorkerNotificationsController extends _$WorkerNotificationsController {
  SupabaseClient get _supabase => ref.read(supabaseProvider);

  @override
  bool build() {
    Future.microtask(() => loadNotifications());
    return false;
  }

  Future<void> loadNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final notificationsData = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      state = notificationsData.isNotEmpty;
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }
}