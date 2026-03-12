import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/supabase_client.dart';
import 'package:riverpod/riverpod.dart';

part 'services_provider.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> popularServices(Ref ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase
      .from('services')
      .select('id, name')
      .eq('is_popular', true)
      .order('name');

  return response;
}

@riverpod
Future<List<Map<String, dynamic>>> allServices(Ref ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase
      .from('services')
      .select('id , name')
      .order('name');

  return response;
}
