import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/auth_providers.dart';
import '../../domain/service_model.dart';
import 'package:riverpod/riverpod.dart';
import '../../domain/task_model.dart';

part 'services_provider.g.dart';

@riverpod
Future<List<ServiceModel>> popularServices(PopularServicesRef ref) async {
  final supabase = ref.read(supabaseProvider);
  try {
    final response = await supabase
        .from('services')
        .select('id, name')
        .eq('is_popular', true)
        .order('name');
    return (response as List).map((e) => ServiceModel.fromMap(e)).toList();
  } catch (e) {
    throw Exception('Error cargando servicios populares: $e');
  }
}

@riverpod
Future<List<ServiceModel>> allServices(AllServicesRef ref) async {
  ref.keepAlive();
  final supabase = ref.read(supabaseProvider);

  try {
    final response = await supabase
        .from('services')
        .select('id, name')
        .order('name');

    return (response as List).map((e) => ServiceModel.fromMap(e)).toList();
  } catch (e) {
    throw Exception('Error cargando servicios: $e');
  }
}

@riverpod
Future<List<TaskModel>> tasksList(TasksListRef ref) async {
  final supabase = ref.read(supabaseProvider);
  try {
    final response = await supabase
        .from('tasks')
        .select('id, name')
        .order('name');

    return (response as List).map((e) => TaskModel.fromMap(e)).toList();
  } catch (e) {
    throw Exception('Error cargando servicios populares: $e');
  }
}
