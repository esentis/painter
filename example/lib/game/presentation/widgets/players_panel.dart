import 'package:flutter/material.dart';

import '../../domain/entities/player.dart';

class PlayersPanel extends StatelessWidget {
  final List<Player> players;
  final String? drawerId;

  const PlayersPanel({super.key, required this.players, this.drawerId});

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const Center(child: Text('Waiting for players...'));
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: players.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final player = players[index];
        final isDrawing = player.id == drawerId;
        return ListTile(
          dense: true,
          leading: Icon(
            isDrawing ? Icons.brush : Icons.person,
            color: isDrawing
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          title: Text(
            player.name + (player.isHost ? ' (host)' : ''),
            style: TextStyle(
              fontWeight: isDrawing ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: Text(
            '${player.score} pts',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      },
    );
  }
}
