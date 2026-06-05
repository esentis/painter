import 'package:painter/src/draw_event.dart';

import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/game_control.dart';
import '../../../domain/entities/player.dart';

sealed class GameEvent {
  const GameEvent();
}

class GameInitialized extends GameEvent {
  const GameInitialized();
}

class GamePlayersUpdated extends GameEvent {
  final List<Player> players;
  const GamePlayersUpdated(this.players);
}

class GameStartRequested extends GameEvent {
  const GameStartRequested();
}

class GameControlReceived extends GameEvent {
  final GameControl control;
  const GameControlReceived(this.control);
}

class GameDrawEventSent extends GameEvent {
  final DrawEvent drawEvent;
  const GameDrawEventSent(this.drawEvent);
}

class GameDrawEventReceived extends GameEvent {
  final DrawEvent drawEvent;
  const GameDrawEventReceived(this.drawEvent);
}

class GameGuessSubmitted extends GameEvent {
  final String text;
  const GameGuessSubmitted(this.text);
}

class GameChatMessageReceived extends GameEvent {
  final ChatMessage message;
  const GameChatMessageReceived(this.message);
}

class GameTimerTick extends GameEvent {
  const GameTimerTick();
}
