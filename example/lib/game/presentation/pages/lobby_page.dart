import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/room_repository.dart';
import '../bloc/game/game_bloc.dart';
import '../bloc/game/game_event.dart';
import '../bloc/lobby/lobby_bloc.dart';
import '../bloc/lobby/lobby_event.dart';
import '../bloc/lobby/lobby_state.dart';
import 'game_page.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: BlocConsumer<LobbyBloc, LobbyState>(
            listener: (context, state) {
              if (state.status == LobbyStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error ?? 'Something went wrong')),
                );
              }
              if (state.status == LobbyStatus.joined) {
                _navigateToGame(context, state);
              }
            },
            builder: (context, state) {
              return switch (state.status) {
                LobbyStatus.initial => _buildNameInput(context),
                LobbyStatus.named => _buildRoomOptions(context),
                LobbyStatus.joining => const Center(
                    child: CircularProgressIndicator(),
                  ),
                LobbyStatus.error => _buildRoomOptions(context),
                LobbyStatus.joined => const SizedBox.shrink(),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNameInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Draw & Guess',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Your name',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitName(context),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _submitName(context),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Draw & Guess',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () =>
                context.read<LobbyBloc>().add(const LobbyCreateRoom()),
            icon: const Icon(Icons.add),
            label: const Text('Create Room'),
          ),
          const SizedBox(height: 24),
          const Text('— or —'),
          const SizedBox(height: 24),
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Room code',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => _joinRoom(context),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _joinRoom(context),
            icon: const Icon(Icons.login),
            label: const Text('Join Room'),
          ),
        ],
      ),
    );
  }

  void _submitName(BuildContext context) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    context.read<LobbyBloc>().add(LobbyNameSubmitted(name));
  }

  void _joinRoom(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    context.read<LobbyBloc>().add(LobbyJoinRoom(code));
  }

  void _navigateToGame(BuildContext context, LobbyState state) {
    final repository = context.read<RoomRepository>();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GameBloc(
            repository: repository,
            localPlayerId: state.playerId,
            localPlayerName: state.username,
            isHost: state.isHost,
            roomCode: state.roomCode,
          )..add(const GameInitialized()),
          child: GamePage(roomCode: state.roomCode),
        ),
      ),
    );
  }
}
