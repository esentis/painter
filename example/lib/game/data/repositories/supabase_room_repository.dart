import 'dart:async';

import 'package:painter/src/draw_event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/game_control.dart';
import '../../domain/entities/player.dart';
import '../../domain/repositories/room_repository.dart';

class SupabaseRoomRepository implements RoomRepository {
  final SupabaseClient _client;
  RealtimeChannel? _channel;

  final _playersController = StreamController<List<Player>>.broadcast();
  final _drawController = StreamController<DrawEvent>.broadcast();
  final _chatController = StreamController<ChatMessage>.broadcast();
  final _gameControlController = StreamController<GameControl>.broadcast();

  SupabaseRoomRepository(this._client);

  @override
  Stream<List<Player>> get onPlayersChanged => _playersController.stream;

  @override
  Stream<DrawEvent> get onDrawEvent => _drawController.stream;

  @override
  Stream<ChatMessage> get onChatMessage => _chatController.stream;

  @override
  Stream<GameControl> get onGameControl => _gameControlController.stream;

  @override
  Future<void> connect(String roomCode, Player localPlayer) async {
    final completer = Completer<void>();

    _channel = _client.channel(
      'room:$roomCode',
      opts: const RealtimeChannelConfig(self: false),
    );

    _channel!
        .onBroadcast(event: 'draw', callback: (payload) {
          _drawController.add(DrawEvent.fromJson(payload));
        })
        .onBroadcast(event: 'guess', callback: (payload) {
          _chatController.add(ChatMessage.fromJson(payload));
        })
        .onBroadcast(event: 'game_control', callback: (payload) {
          _gameControlController.add(GameControl.fromJson(payload));
        })
        .onPresenceSync((payload) {
          final states = _channel!.presenceState();
          final players = <Player>[];
          for (final state in states) {
            for (final presence in state.presences) {
              players.add(Player.fromJson(presence.payload));
            }
          }
          _playersController.add(players);
        })
        .subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            _channel!.track(localPlayer.toJson());
            if (!completer.isCompleted) completer.complete();
          } else if (status == RealtimeSubscribeStatus.channelError) {
            if (!completer.isCompleted) {
              completer.completeError(error ?? 'Channel subscription failed');
            }
          }
        });

    return completer.future;
  }

  @override
  Future<void> disconnect() async {
    await _channel?.untrack();
    await _channel?.unsubscribe();
    _channel = null;
  }

  @override
  void sendDrawEvent(DrawEvent event) {
    _channel?.sendBroadcastMessage(
      event: 'draw',
      payload: Map.from(event.toJson()),
    );
  }

  @override
  void sendGuess(ChatMessage message) {
    _channel?.sendBroadcastMessage(
      event: 'guess',
      payload: Map.from(message.toJson()),
    );
    _chatController.add(message);
  }

  @override
  void sendGameControl(GameControl control) {
    _channel?.sendBroadcastMessage(
      event: 'game_control',
      payload: Map.from(control.toJson()),
    );
  }
}
