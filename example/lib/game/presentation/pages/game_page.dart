import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painter/src/event_painter_controller.dart';
import 'package:painter/src/playback_painter.dart';

import '../bloc/game/game_bloc.dart';
import '../bloc/game/game_event.dart';
import '../bloc/game/game_state.dart';
import '../widgets/chat_panel.dart';
import '../widgets/players_panel.dart';

class GamePage extends StatefulWidget {
  final String roomCode;

  const GamePage({super.key, required this.roomCode});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final _drawController = EventPainterController();
  final _playbackController = PlaybackController();
  double _thickness = 5.0;
  Color _selectedColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _drawController.thickness = _thickness;
    _drawController.drawColor = _selectedColor;

    final bloc = context.read<GameBloc>();
    final repository = bloc.repository;

    _drawController.events.listen((event) {
      bloc.add(GameDrawEventSent(event));
    });

    _playbackController.listen(repository.onDrawEvent);
  }

  @override
  void dispose() {
    _drawController.dispose();
    _playbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Room: ${widget.roomCode}'),
            actions: _buildAppBarActions(state),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  List<Widget> _buildAppBarActions(GameState state) {
    return [
      if (state.phase == GamePhase.playing)
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${state.timeLeft}s',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: state.timeLeft <= 10 ? Colors.red : null,
              ),
            ),
          ),
        ),
      if (state.isDrawer && state.phase == GamePhase.playing) ...[
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: () {
            _drawController.undo();
          },
          tooltip: 'Undo',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            _drawController.clear();
          },
          tooltip: 'Clear',
        ),
      ],
    ];
  }

  Widget _buildBody(BuildContext context, GameState state) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Column(
      children: [
        if (state.phase == GamePhase.playing && state.isDrawer)
          _buildDrawToolbar(),
        if (state.phase == GamePhase.playing && state.isDrawer)
          _buildWordBanner(state),
        Expanded(
          child: isWide
              ? _buildWideLayout(context, state)
              : _buildNarrowLayout(context, state),
        ),
      ],
    );
  }

  Widget _buildWordBanner(GameState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        'Draw: ${state.currentWord}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildDrawToolbar() {
    const colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.brown,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          ...colors.map((c) {
            final selected = _selectedColor == c;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedColor = c;
                _drawController.drawColor = c;
              }),
              child: Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: selected ? 3 : 0,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: _thickness,
              min: 2,
              max: 20,
              onChanged: (v) => setState(() {
                _thickness = v;
                _drawController.thickness = v;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, GameState state) {
    return Row(
      children: [
        SizedBox(
          width: 180,
          child: Column(
            children: [
              _sectionHeader('Players'),
              Expanded(
                child: PlayersPanel(
                  players: state.players,
                  drawerId: state.drawerId,
                ),
              ),
              if (state.canStart && state.phase == GamePhase.waiting)
                _startButton(context),
              if (state.isHost && state.phase == GamePhase.roundEnd)
                _nextRoundButton(context),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: _buildCanvas(state)),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _sectionHeader('Chat'),
              Expanded(child: _buildChat(context, state)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, GameState state) {
    return Column(
      children: [
        if (state.phase == GamePhase.waiting) ...[
          _sectionHeader('Players'),
          SizedBox(
            height: 120,
            child: PlayersPanel(
              players: state.players,
              drawerId: state.drawerId,
            ),
          ),
          if (state.canStart) _startButton(context),
        ],
        if (state.isHost && state.phase == GamePhase.roundEnd)
          _nextRoundButton(context),
        Expanded(flex: 3, child: _buildCanvas(state)),
        Expanded(flex: 2, child: _buildChat(context, state)),
      ],
    );
  }

  Widget _buildCanvas(GameState state) {
    if (state.phase == GamePhase.waiting) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.brush, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              state.isHost
                  ? 'Waiting for players to join...\nShare code: ${state.roomCode}'
                  : 'Waiting for host to start...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (state.isHost)
              FilledButton.tonalIcon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: state.roomCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copied!')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: Text(state.roomCode),
              ),
          ],
        ),
      );
    }

    if (state.phase == GamePhase.gameOver) {
      final sorted = [...state.players]..sort((a, b) => b.score - a.score);
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Game Over!',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            ...sorted.map((p) => Text(
                  '${p.name}: ${p.score} pts',
                  style: Theme.of(context).textTheme.titleMedium,
                )),
          ],
        ),
      );
    }

    if (state.isDrawer) {
      return DrawCanvas(controller: _drawController);
    }

    return PlaybackCanvas(controller: _playbackController);
  }

  Widget _buildChat(BuildContext context, GameState state) {
    return ChatPanel(
      messages: state.messages,
      canGuess:
          state.phase == GamePhase.playing && state.role == PlayerRole.guesser,
      onGuessSubmitted: (text) {
        context.read<GameBloc>().add(GameGuessSubmitted(text));
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget _startButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FilledButton.icon(
        onPressed: () =>
            context.read<GameBloc>().add(const GameStartRequested()),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start'),
      ),
    );
  }

  Widget _nextRoundButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FilledButton.icon(
        onPressed: () => context.read<GameBloc>().startNextRound(),
        icon: const Icon(Icons.skip_next),
        label: const Text('Next Round'),
      ),
    );
  }
}
