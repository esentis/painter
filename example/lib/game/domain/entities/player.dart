import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final int score;
  final bool isHost;

  const Player({
    required this.id,
    required this.name,
    this.score = 0,
    this.isHost = false,
  });

  Player copyWith({int? score, bool? isHost}) => Player(
        id: id,
        name: name,
        score: score ?? this.score,
        isHost: isHost ?? this.isHost,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'score': score,
        'is_host': isHost,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        score: json['score'] as int? ?? 0,
        isHost: json['is_host'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, name, score, isHost];
}
