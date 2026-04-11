// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$popularServicesHash() => r'd12ebb548be657f903eac576534fcd55113cf9f5';

/// See also [popularServices].
@ProviderFor(popularServices)
final popularServicesProvider =
    AutoDisposeFutureProvider<List<ServiceModel>>.internal(
      popularServices,
      name: r'popularServicesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$popularServicesHash,
      dependencies: [supabaseProvider],
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PopularServicesRef = AutoDisposeFutureProviderRef<List<ServiceModel>>;
String _$allServicesHash() => r'a03594ef9181d352ada7e9ed2805ac518e8867a0';

/// See also [allServices].
@ProviderFor(allServices)
final allServicesProvider =
    AutoDisposeFutureProvider<List<ServiceModel>>.internal(
      allServices,
      name: r'allServicesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allServicesHash,
      dependencies: [supabaseProvider],
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllServicesRef = AutoDisposeFutureProviderRef<List<ServiceModel>>;
String _$tasksListHash() => r'ff07084ab4662d831f315bcb5ee749fc75fd3417';

/// See also [tasksList].
@ProviderFor(tasksList)
final tasksListProvider = AutoDisposeFutureProvider<List<TaskModel>>.internal(
  tasksList,
  name: r'tasksListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tasksListHash,
  dependencies: [supabaseProvider],
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TasksListRef = AutoDisposeFutureProviderRef<List<TaskModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
