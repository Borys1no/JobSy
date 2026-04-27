import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/core/config/supabase_client.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:jobsy/features/client/domain/chat_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'chat_controller.g.dart';

@riverpod
class ChatController extends _$ChatController {
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
        final isClient = chat['client_id'] == userId;
        final otherId = isClient ? chat['worker_id'] : chat['client_id'];
        final role = isClient ? 'worker' : 'client';

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

        if (isClient) {
          conversations.add(ChatConversation(
            id: chat['id'] as String,
            chatId: chat['id'] as String,
            clientId: userId,
            workerId: otherId,
            clientName: 'Tú',
            workerName: name,
            workerAvatar: avatar,
            lastMessage: lastMessage,
            lastMessageAt: lastMessageAt,
            hasUnreadMessages: hasUnread,
          ));
        } else {
          final clientData = await _supabase
              .from('profiles')
              .select('first_name, last_name, avatar_url')
              .eq('id', chat['client_id'])
              .maybeSingle();

          conversations.add(ChatConversation(
            id: chat['id'] as String,
            chatId: chat['id'] as String,
            clientId: chat['client_id'] as String,
            workerId: userId,
            clientName: '${clientData?['first_name'] ?? ''} ${clientData?['last_name'] ?? ''}'.trim(),
            workerName: name,
            clientAvatar: clientData?['avatar_url'] as String?,
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
      print('Error loading chats: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<String?> createOrGetChat(String workerId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final existingChat = await _supabase
          .from('chats')
          .select('id')
          .or('and(client_id.eq.$userId,worker_id.eq.$workerId),and(client_id.eq.$workerId,worker_id.eq.$userId)')
          .maybeSingle();

      if (existingChat != null) {
        return existingChat['id'] as String;
      }

      final newChat = await _supabase.from('chats').insert({
        'client_id': userId,
        'worker_id': workerId,
      }).select().single();

      return newChat['id'] as String;
    } catch (e) {
      print('Error creating chat: $e');
      return null;
    }
  }
}

@riverpod
class ChatMessagesController extends _$ChatMessagesController {
  SupabaseClient get _supabase => ref.read(supabaseProvider);

  @override
  ChatMessagesState build(String chatId) {
    Future.microtask(() => loadMessages(chatId));
    print('Building ChatMessagesController for chatId: $chatId');
    return ChatMessagesState.initial(chatId);
  }

  Future<void> loadMessages(String chatId) async {
    try {
      print('Loading messages for chatId: $chatId');
      state = state.copyWith(isLoading: true);

      final chatData = await _supabase
          .from('chats')
          .select()
          .eq('id', chatId)
          .single();
      
      print('Chat data found: $chatData');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('User is null!');
        return;
      }
      
      print('Current user: $userId');

      final isClient = chatData['client_id'] == userId;
      final otherId = isClient ? chatData['worker_id'] : chatData['client_id'];

      print('isClient: $isClient, otherId: $otherId');

      final profileData = await _supabase
          .from('profiles')
          .select('first_name, last_name, avatar_url')
          .eq('id', otherId)
          .maybeSingle();

      final workerName = profileData != null 
          ? '${profileData['first_name'] ?? ''} ${profileData['last_name'] ?? ''}'.trim()
          : 'Usuario';
      final workerAvatar = profileData?['avatar_url'] as String?;

      final messagesData = await _supabase
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);
      
      print('Messages found: ${messagesData.length}');
      print('Messages: $messagesData');

        final messages = messagesData.map((m) => ChatMessage(
          id: m['id'] as String,
          chatId: m['chat_id'] as String,
          senderId: m['sender_id'] as String,
          content: m['content'] as String? ?? '',
          createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now(),
        )).toList();

        await _supabase
            .from('messages')
            .update({'is_read': true})
            .eq('chat_id', chatId)
            .neq('sender_id', userId);

        state = state.copyWith(
          isLoading: false,
          workerId: otherId,
          workerName: workerName,
          workerAvatar: workerAvatar,
          messages: messages,
        );
    } catch (e) {
      print('Error loading messages: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendMessage(String chatId, String content) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final newMessage = await _supabase.from('messages').insert({
        'chat_id': chatId,
        'sender_id': userId,
        'content': content,
      }).select().single();

      final message = ChatMessage(
        id: newMessage['id'] as String,
        chatId: newMessage['chat_id'] as String,
        senderId: newMessage['sender_id'] as String,
        content: newMessage['content'] as String? ?? '',
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, message],
      );

      final chatData = await _supabase
          .from('chats')
          .select('client_id, worker_id')
          .eq('id', chatId)
          .single();

      final recipientId = chatData['client_id'] == userId 
          ? chatData['worker_id'] 
          : chatData['client_id'];

      final profileData = await _supabase
          .from('profiles')
          .select('first_name')
          .eq('id', userId)
          .maybeSingle();

      final senderName = profileData?['first_name'] as String? ?? 'Usuario';

      await _supabase.from('notifications').insert({
        'user_id': recipientId,
        'type': 'message',
        'title': 'Nuevo mensaje de $senderName',
        'body': content.length > 50 ? '${content.substring(0, 50)}...' : content,
        'from_user_id': userId,
        'chat_id': chatId,
        'is_read': false,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}