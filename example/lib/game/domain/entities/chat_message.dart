import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String playerName;
  final String text;
  final bool isCorrectGuess;
  final DateTime timestamp;

  ChatMessage({
    required this.playerName,
    required this.text,
    this.isCorrectGuess = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'player_name': playerName,
        'text': text,
        'is_correct': isCorrectGuess,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        playerName: json['player_name'] as String,
        text: json['text'] as String,
        isCorrectGuess: json['is_correct'] as bool? ?? false,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          json['timestamp'] as int,
        ),
      );

  @override
  List<Object?> get props => [playerName, text, isCorrectGuess, timestamp];
}
