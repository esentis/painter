enum DrawEventType { strokeStart, strokeUpdate, strokeEnd, undo, clear }

class DrawEvent {
  final DrawEventType type;
  final double? x;
  final double? y;
  final int? color;
  final double? thickness;
  final DateTime timestamp;

  DrawEvent({
    required this.type,
    this.x,
    this.y,
    this.color,
    this.thickness,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory DrawEvent.strokeStart({
    required double x,
    required double y,
    required int color,
    required double thickness,
  }) =>
      DrawEvent(
        type: DrawEventType.strokeStart,
        x: x,
        y: y,
        color: color,
        thickness: thickness,
      );

  factory DrawEvent.strokeUpdate({required double x, required double y}) =>
      DrawEvent(type: DrawEventType.strokeUpdate, x: x, y: y);

  factory DrawEvent.strokeEnd() => DrawEvent(type: DrawEventType.strokeEnd);

  factory DrawEvent.undo() => DrawEvent(type: DrawEventType.undo);

  factory DrawEvent.clear() => DrawEvent(type: DrawEventType.clear);

  Map<String, dynamic> toJson() => {
        'kind': type.name,
        'x': x,
        'y': y,
        'color': color,
        'thickness': thickness,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory DrawEvent.fromJson(Map<String, dynamic> json) => DrawEvent(
        type: DrawEventType.values.byName(json['kind'] as String),
        x: (json['x'] as num?)?.toDouble(),
        y: (json['y'] as num?)?.toDouble(),
        color: json['color'] as int?,
        thickness: (json['thickness'] as num?)?.toDouble(),
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      );
}
