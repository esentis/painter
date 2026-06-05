import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/player.dart';

enum GamePhase { waiting, playing, roundEnd, gameOver }

enum PlayerRole { drawer, guesser }

class GameState extends Equatable {
  final GamePhase phase;
  final PlayerRole role;
  final List<Player> players;
  final List<ChatMessage> messages;
  final String? currentWord;
  final String? drawerId;
  final int roundNumber;
  final int timeLeft;
  final String localPlayerId;
  final String localPlayerName;
  final bool isHost;
  final String roomCode;

  const GameState({
    this.phase = GamePhase.waiting,
    this.role = PlayerRole.guesser,
    this.players = const [],
    this.messages = const [],
    this.currentWord,
    this.drawerId,
    this.roundNumber = 0,
    this.timeLeft = 60,
    required this.localPlayerId,
    required this.localPlayerName,
    required this.isHost,
    required this.roomCode,
  });

  bool get isDrawer => role == PlayerRole.drawer;
  bool get canStart => isHost && players.length >= 2;

  GameState copyWith({
    GamePhase? phase,
    PlayerRole? role,
    List<Player>? players,
    List<ChatMessage>? messages,
    String? currentWord,
    String? drawerId,
    int? roundNumber,
    int? timeLeft,
  }) =>
      GameState(
        phase: phase ?? this.phase,
        role: role ?? this.role,
        players: players ?? this.players,
        messages: messages ?? this.messages,
        currentWord: currentWord ?? this.currentWord,
        drawerId: drawerId ?? this.drawerId,
        roundNumber: roundNumber ?? this.roundNumber,
        timeLeft: timeLeft ?? this.timeLeft,
        localPlayerId: localPlayerId,
        localPlayerName: localPlayerName,
        isHost: isHost,
        roomCode: roomCode,
      );

  @override
  List<Object?> get props => [
        phase,
        role,
        players,
        messages,
        currentWord,
        drawerId,
        roundNumber,
        timeLeft,
      ];
}
