import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/supabase_room_repository.dart';
import 'domain/repositories/room_repository.dart';
import 'presentation/bloc/lobby/lobby_bloc.dart';
import 'presentation/pages/lobby_page.dart';

class DrawGuessApp extends StatelessWidget {
  final SupabaseRoomRepository repository;

  const DrawGuessApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<RoomRepository>.value(
      value: repository,
      child: MaterialApp(
        title: 'Draw & Guess',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: BlocProvider(
          create: (context) => LobbyBloc(context.read<RoomRepository>()),
          child: const LobbyPage(),
        ),
      ),
    );
  }
}
