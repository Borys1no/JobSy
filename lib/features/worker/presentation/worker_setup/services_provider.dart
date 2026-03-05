import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_client.dart';
import 'package:riverpod/riverpod.dart';

part 'services_provider.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> servicesList(Ref ref) async {
  // Cambiado de ServicesListRef a Ref
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase
      .from('services')
      .select('id, name')
      .order('name');

  return response;
}
