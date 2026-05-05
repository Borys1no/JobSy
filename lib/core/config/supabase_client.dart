import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  static final anonKey = dotenv.env['ANONKEY']!;
}
