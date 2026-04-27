// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatControllerHash() => r'94f367145360fd1da93236cd6c8fa0335930b365';

/// See also [ChatController].
@ProviderFor(ChatController)
final chatControllerProvider =
    AutoDisposeNotifierProvider<ChatController, ChatListState>.internal(
      ChatController.new,
      name: r'chatControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatController = AutoDisposeNotifier<ChatListState>;
String _$chatMessagesControllerHash() =>
    r'42959fd1df0f69b98e9f0853434ed144fbd283c1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ChatMessagesController
    extends BuildlessAutoDisposeNotifier<ChatMessagesState> {
  late final String chatId;

  ChatMessagesState build(String chatId);
}

/// See also [ChatMessagesController].
@ProviderFor(ChatMessagesController)
const chatMessagesControllerProvider = ChatMessagesControllerFamily();

/// See also [ChatMessagesController].
class ChatMessagesControllerFamily extends Family<ChatMessagesState> {
  /// See also [ChatMessagesController].
  const ChatMessagesControllerFamily();

  /// See also [ChatMessagesController].
  ChatMessagesControllerProvider call(String chatId) {
    return ChatMessagesControllerProvider(chatId);
  }

  @override
  ChatMessagesControllerProvider getProviderOverride(
    covariant ChatMessagesControllerProvider provider,
  ) {
    return call(provider.chatId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatMessagesControllerProvider';
}

/// See also [ChatMessagesController].
class ChatMessagesControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          ChatMessagesController,
          ChatMessagesState
        > {
  /// See also [ChatMessagesController].
  ChatMessagesControllerProvider(String chatId)
    : this._internal(
        () => ChatMessagesController()..chatId = chatId,
        from: chatMessagesControllerProvider,
        name: r'chatMessagesControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatMessagesControllerHash,
        dependencies: ChatMessagesControllerFamily._dependencies,
        allTransitiveDependencies:
            ChatMessagesControllerFamily._allTransitiveDependencies,
        chatId: chatId,
      );

  ChatMessagesControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
  }) : super.internal();

  final String chatId;

  @override
  ChatMessagesState runNotifierBuild(
    covariant ChatMessagesController notifier,
  ) {
    return notifier.build(chatId);
  }

  @override
  Override overrideWith(ChatMessagesController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatMessagesControllerProvider._internal(
        () => create()..chatId = chatId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ChatMessagesController, ChatMessagesState>
  createElement() {
    return _ChatMessagesControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesControllerProvider && other.chatId == chatId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatMessagesControllerRef
    on AutoDisposeNotifierProviderRef<ChatMessagesState> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _ChatMessagesControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          ChatMessagesController,
          ChatMessagesState
        >
    with ChatMessagesControllerRef {
  _ChatMessagesControllerProviderElement(super.provider);

  @override
  String get chatId => (origin as ChatMessagesControllerProvider).chatId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
