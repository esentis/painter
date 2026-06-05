import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'game/app.dart';
import 'game/core/supabase_config.dart';
import 'game/data/repositories/supabase_room_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(
    SupabaseConfig.supabaseUrl.isNotEmpty &&
        SupabaseConfig.supabaseAnonKey.isNotEmpty,
    'Pass --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>',
  );

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
  );

  final repository = SupabaseRoomRepository(Supabase.instance.client);

  runApp(DrawGuessApp(repository: repository));
}
