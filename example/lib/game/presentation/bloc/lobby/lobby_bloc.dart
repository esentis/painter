import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/player.dart';
import '../../../domain/repositories/room_repository.dart';
import 'lobby_event.dart';
import 'lobby_state.dart';

class LobbyBloc extends Bloc<LobbyEvent, LobbyState> {
  final RoomRepository _repository;

  LobbyBloc(this._repository) : super(const LobbyState()) {
    on<LobbyNameSubmitted>(_onNameSubmitted);
    on<LobbyCreateRoom>(_onCreateRoom);
    on<LobbyJoinRoom>(_onJoinRoom);
  }

  void _onNameSubmitted(LobbyNameSubmitted event, Emitter<LobbyState> emit) {
    final id = _generateId();
    emit(state.copyWith(
      status: LobbyStatus.named,
      username: event.name.trim(),
      playerId: id,
    ));
  }

  Future<void> _onCreateRoom(
    LobbyCreateRoom event,
    Emitter<LobbyState> emit,
  ) async {
    final code = _generateRoomCode();
    emit(state.copyWith(status: LobbyStatus.joining, roomCode: code));

    try {
      final player = Player(
        id: state.playerId,
        name: state.username,
        isHost: true,
      );
      await _repository.connect(code, player);
      emit(state.copyWith(status: LobbyStatus.joined, isHost: true));
    } catch (e) {
      emit(state.copyWith(
        status: LobbyStatus.error,
        error: 'Failed to create room: $e',
      ));
    }
  }

  Future<void> _onJoinRoom(
    LobbyJoinRoom event,
    Emitter<LobbyState> emit,
  ) async {
    final code = event.code.trim().toUpperCase();
    emit(state.copyWith(status: LobbyStatus.joining, roomCode: code));

    try {
      final player = Player(
        id: state.playerId,
        name: state.username,
      );
      await _repository.connect(code, player);
      emit(state.copyWith(status: LobbyStatus.joined, isHost: false));
    } catch (e) {
      emit(state.copyWith(
        status: LobbyStatus.error,
        error: 'Failed to join room: $e',
      ));
    }
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    return List.generate(5, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
      Random().nextInt(9999).toRadixString(36);
}
