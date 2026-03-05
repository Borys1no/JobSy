import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
export 'features/worker/presentation/worker_setup/worker_setup_controller.dart';
export 'features/worker/presentation/worker_setup/services_provider.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
