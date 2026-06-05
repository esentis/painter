import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/words.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/game_control.dart';
import '../../../domain/repositories/room_repository.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final RoomRepository _repository;
  final List<StreamSubscription> _subscriptions = [];
  Timer? _roundTimer;

  RoomRepository get repository => _repository;

  GameBloc({
    required RoomRepository repository,
    required String localPlayerId,
    required String localPlayerName,
    required bool isHost,
    required String roomCode,
  })  : _repository = repository,
        super(GameState(
          localPlayerId: localPlayerId,
          localPlayerName: localPlayerName,
          isHost: isHost,
          roomCode: roomCode,
        )) {
    on<GameInitialized>(_onInitialized);
    on<GamePlayersUpdated>(_onPlayersUpdated);
    on<GameStartRequested>(_onStartRequested);
    on<GameControlReceived>(_onControlReceived);
    on<GameDrawEventSent>(_onDrawEventSent);
    on<GameDrawEventReceived>(_onDrawEventReceived);
    on<GameGuessSubmitted>(_onGuessSubmitted);
    on<GameChatMessageReceived>(_onChatMessageReceived);
    on<GameTimerTick>(_onTimerTick);
  }

  void _onInitialized(GameInitialized event, Emitter<GameState> emit) {
    _subscriptions.addAll([
      _repository.onPlayersChanged.listen(
        (players) => add(GamePlayersUpdated(players)),
      ),
      _repository.onDrawEvent.listen(
        (e) => add(GameDrawEventReceived(e)),
      ),
      _repository.onChatMessage.listen(
        (m) => add(GameChatMessageReceived(m)),
      ),
      _repository.onGameControl.listen(
        (c) => add(GameControlReceived(c)),
      ),
    ]);
  }

  void _onPlayersUpdated(GamePlayersUpdated event, Emitter<GameState> emit) {
    emit(state.copyWith(players: event.players));
  }

  void _onStartRequested(GameStartRequested event, Emitter<GameState> emit) {
    if (!state.isHost || state.players.length < 2) return;
    _broadcastRoundStart(1);
  }

  void _onControlReceived(
    GameControlReceived event,
    Emitter<GameState> emit,
  ) {
    final control = event.control;
    switch (control.type) {
      case GameControlType.roundStart:
        final isDrawer = control.drawerId == state.localPlayerId;
        _startTimer();
        emit(state.copyWith(
          phase: GamePhase.playing,
          role: isDrawer ? PlayerRole.drawer : PlayerRole.guesser,
          currentWord: control.word,
          drawerId: control.drawerId,
          roundNumber: control.roundNumber,
          timeLeft: 60,
          messages: [],
        ));
      case GameControlType.correctGuess:
        _cancelTimer();
        final players = state.players.map((p) {
          if (p.name == control.playerName) return p.copyWith(score: p.score + 2);
          if (p.id == state.drawerId) return p.copyWith(score: p.score + 1);
          return p;
        }).toList();
        emit(state.copyWith(
          phase: GamePhase.roundEnd,
          players: players,
          messages: [
            ...state.messages,
            ChatMessage(
              playerName: 'System',
              text: '${control.playerName} guessed it! The word was "${control.word}"',
              isCorrectGuess: true,
            ),
          ],
        ));
      case GameControlType.roundEnd:
        _cancelTimer();
        emit(state.copyWith(
          phase: GamePhase.roundEnd,
          messages: [
            ...state.messages,
            ChatMessage(
              playerName: 'System',
              text: 'Time\'s up! The word was "${control.word}"',
            ),
          ],
        ));
      case GameControlType.gameEnd:
        _cancelTimer();
        emit(state.copyWith(phase: GamePhase.gameOver));
    }
  }

  void _onDrawEventSent(GameDrawEventSent event, Emitter<GameState> emit) {
    _repository.sendDrawEvent(event.drawEvent);
  }

  void _onDrawEventReceived(
    GameDrawEventReceived event,
    Emitter<GameState> emit,
  ) {
    // Handled by PlaybackController directly via stream
  }

  void _onGuessSubmitted(GameGuessSubmitted event, Emitter<GameState> emit) {
    final text = event.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      playerName: state.localPlayerName,
      text: text,
    );
    _repository.sendGuess(message);

    if (state.isHost && _isCorrectGuess(text)) {
      final control = GameControl.correctGuess(
        playerName: state.localPlayerName,
        word: state.currentWord!,
      );
      _repository.sendGameControl(control);
      add(GameControlReceived(control));
    }
  }

  void _onChatMessageReceived(
    GameChatMessageReceived event,
    Emitter<GameState> emit,
  ) {
    emit(state.copyWith(
      messages: [...state.messages, event.message],
    ));

    if (state.isHost && _isCorrectGuess(event.message.text)) {
      final control = GameControl.correctGuess(
        playerName: event.message.playerName,
        word: state.currentWord!,
      );
      _repository.sendGameControl(control);
      add(GameControlReceived(control));
    }
  }

  void _onTimerTick(GameTimerTick event, Emitter<GameState> emit) {
    final newTime = state.timeLeft - 1;
    if (newTime <= 0) {
      _cancelTimer();
      if (state.isHost) {
        final control = GameControl.roundEnd(word: state.currentWord!);
        _repository.sendGameControl(control);
        add(GameControlReceived(control));
      }
      return;
    }
    emit(state.copyWith(timeLeft: newTime));
  }

  void _broadcastRoundStart(int roundNumber) {
    final drawerIndex = (roundNumber - 1) % state.players.length;
    final drawer = state.players[drawerIndex];
    final word = getRandomWord();

    final control = GameControl.roundStart(
      word: word,
      drawerId: drawer.id,
      roundNumber: roundNumber,
    );

    _repository.sendGameControl(control);
    add(GameControlReceived(control));
  }

  void startNextRound() {
    if (!state.isHost) return;
    final nextRound = state.roundNumber + 1;
    if (nextRound > state.players.length) {
      _repository.sendGameControl(GameControl.gameEnd());
      add(GameControlReceived(GameControl.gameEnd()));
      return;
    }
    _broadcastRoundStart(nextRound);
  }

  bool _isCorrectGuess(String guess) {
    if (state.currentWord == null || state.phase != GamePhase.playing) {
      return false;
    }
    return guess.trim().toLowerCase() == state.currentWord!.toLowerCase();
  }

  void _startTimer() {
    _cancelTimer();
    _roundTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const GameTimerTick()),
    );
  }

  void _cancelTimer() {
    _roundTimer?.cancel();
    _roundTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    return super.close();
  }
}
