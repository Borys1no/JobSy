// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workerProfileControllerHash() =>
    r'62fe503894368a292361130c6b1082e6e1a7d931';

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

abstract class _$WorkerProfileController
    extends BuildlessAutoDisposeNotifier<WorkerProfileState> {
  late final String workerId;

  WorkerProfileState build(String workerId);
}

/// See also [WorkerProfileController].
@ProviderFor(WorkerProfileController)
const workerProfileControllerProvider = WorkerProfileControllerFamily();

/// See also [WorkerProfileController].
class WorkerProfileControllerFamily extends Family<WorkerProfileState> {
  /// See also [WorkerProfileController].
  const WorkerProfileControllerFamily();

  /// See also [WorkerProfileController].
  WorkerProfileControllerProvider call(String workerId) {
    return WorkerProfileControllerProvider(workerId);
  }

  @override
  WorkerProfileControllerProvider getProviderOverride(
    covariant WorkerProfileControllerProvider provider,
  ) {
    return call(provider.workerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'workerProfileControllerProvider';
}

/// See also [WorkerProfileController].
class WorkerProfileControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          WorkerProfileController,
          WorkerProfileState
        > {
  /// See also [WorkerProfileController].
  WorkerProfileControllerProvider(String workerId)
    : this._internal(
        () => WorkerProfileController()..workerId = workerId,
        from: workerProfileControllerProvider,
        name: r'workerProfileControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$workerProfileControllerHash,
        dependencies: WorkerProfileControllerFamily._dependencies,
        allTransitiveDependencies:
            WorkerProfileControllerFamily._allTransitiveDependencies,
        workerId: workerId,
      );

  WorkerProfileControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.workerId,
  }) : super.internal();

  final String workerId;

  @override
  WorkerProfileState runNotifierBuild(
    covariant WorkerProfileController notifier,
  ) {
    return notifier.build(workerId);
  }

  @override
  Override overrideWith(WorkerProfileController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WorkerProfileControllerProvider._internal(
        () => create()..workerId = workerId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        workerId: workerId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    WorkerProfileController,
    WorkerProfileState
  >
  createElement() {
    return _WorkerProfileControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkerProfileControllerProvider &&
        other.workerId == workerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, workerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WorkerProfileControllerRef
    on AutoDisposeNotifierProviderRef<WorkerProfileState> {
  /// The parameter `workerId` of this provider.
  String get workerId;
}

class _WorkerProfileControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          WorkerProfileController,
          WorkerProfileState
        >
    with WorkerProfileControllerRef {
  _WorkerProfileControllerProviderElement(super.provider);

  @override
  String get workerId => (origin as WorkerProfileControllerProvider).workerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
