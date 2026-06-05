enum GameControlType { roundStart, correctGuess, roundEnd, gameEnd }

class GameControl {
  final GameControlType type;
  final String? word;
  final String? drawerId;
  final String? playerName;
  final int? roundNumber;

  const GameControl({
    required this.type,
    this.word,
    this.drawerId,
    this.playerName,
    this.roundNumber,
  });

  factory GameControl.roundStart({
    required String word,
    required String drawerId,
    required int roundNumber,
  }) =>
      GameControl(
        type: GameControlType.roundStart,
        word: word,
        drawerId: drawerId,
        roundNumber: roundNumber,
      );

  factory GameControl.correctGuess({
    required String playerName,
    required String word,
  }) =>
      GameControl(
        type: GameControlType.correctGuess,
        playerName: playerName,
        word: word,
      );

  factory GameControl.roundEnd({required String word}) =>
      GameControl(type: GameControlType.roundEnd, word: word);

  factory GameControl.gameEnd() =>
      const GameControl(type: GameControlType.gameEnd);

  Map<String, dynamic> toJson() => {
        'kind': type.name,
        'word': word,
        'drawer_id': drawerId,
        'player_name': playerName,
        'round_number': roundNumber,
      };

  factory GameControl.fromJson(Map<String, dynamic> json) => GameControl(
        type: GameControlType.values.byName(json['kind'] as String),
        word: json['word'] as String?,
        drawerId: json['drawer_id'] as String?,
        playerName: json['player_name'] as String?,
        roundNumber: json['round_number'] as int?,
      );
}
