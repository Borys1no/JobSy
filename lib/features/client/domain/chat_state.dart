import 'package:jobsy/features/worker/domain/review.dart';

class ChatListState {
  final bool isLoading;
  final List<ChatConversation> conversations;

  ChatListState({
    required this.isLoading,
    required this.conversations,
  });

  factory ChatListState.initial() => ChatListState(
        isLoading: true,
        conversations: [],
      );

  ChatListState copyWith({
    bool? isLoading,
    List<ChatConversation>? conversations,
  }) {
    return ChatListState(
      isLoading: isLoading ?? this.isLoading,
      conversations: conversations ?? this.conversations,
    );
  }
}

class ChatConversation {
  final String id;
  final String chatId;
  final String clientId;
  final String workerId;
  final String clientName;
  final String? clientAvatar;
  final String workerName;
  final String? workerAvatar;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool hasUnreadMessages;

  ChatConversation({
    required this.id,
    required this.chatId,
    required this.clientId,
    required this.workerId,
    required this.clientName,
    this.clientAvatar,
    required this.workerName,
    this.workerAvatar,
    this.lastMessage,
    this.lastMessageAt,
    this.hasUnreadMessages = false,
  });
}

class ChatMessagesState {
  final bool isLoading;
  final String chatId;
  final String workerId;
  final String workerName;
  final String? workerAvatar;
  final List<ChatMessage> messages;

  ChatMessagesState({
    required this.isLoading,
    required this.chatId,
    required this.workerId,
    required this.workerName,
    this.workerAvatar,
    required this.messages,
  });

  factory ChatMessagesState.initial(String chatId) => ChatMessagesState(
        isLoading: true,
        chatId: chatId,
        workerId: '',
        workerName: '',
        messages: [],
      );

  ChatMessagesState copyWith({
    bool? isLoading,
    String? workerId,
    String? workerName,
    String? workerAvatar,
    List<ChatMessage>? messages,
  }) {
    return ChatMessagesState(
      isLoading: isLoading ?? this.isLoading,
      chatId: chatId,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      workerAvatar: workerAvatar ?? this.workerAvatar,
      messages: messages ?? this.messages,
    );
  }
}

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });
}