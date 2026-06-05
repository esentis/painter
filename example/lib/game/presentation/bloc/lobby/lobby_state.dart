import 'package:equatable/equatable.dart';

enum LobbyStatus { initial, named, joining, joined, error }

class LobbyState extends Equatable {
  final LobbyStatus status;
  final String username;
  final String roomCode;
  final String playerId;
  final bool isHost;
  final String? error;

  const LobbyState({
    this.status = LobbyStatus.initial,
    this.username = '',
    this.roomCode = '',
    this.playerId = '',
    this.isHost = false,
    this.error,
  });

  LobbyState copyWith({
    LobbyStatus? status,
    String? username,
    String? roomCode,
    String? playerId,
    bool? isHost,
    String? error,
  }) =>
      LobbyState(
        status: status ?? this.status,
        username: username ?? this.username,
        roomCode: roomCode ?? this.roomCode,
        playerId: playerId ?? this.playerId,
        isHost: isHost ?? this.isHost,
        error: error,
      );

  @override
  List<Object?> get props =>
      [status, username, roomCode, playerId, isHost, error];
}
