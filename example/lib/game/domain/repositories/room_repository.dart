import 'package:painter/src/draw_event.dart';

import '../entities/chat_message.dart';
import '../entities/game_control.dart';
import '../entities/player.dart';

abstract class RoomRepository {
  Future<void> connect(String roomCode, Player localPlayer);
  Future<void> disconnect();

  Stream<List<Player>> get onPlayersChanged;

  void sendDrawEvent(DrawEvent event);
  Stream<DrawEvent> get onDrawEvent;

  void sendGuess(ChatMessage message);
  Stream<ChatMessage> get onChatMessage;

  void sendGameControl(GameControl control);
  Stream<GameControl> get onGameControl;
}
