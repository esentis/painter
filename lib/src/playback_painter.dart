import 'dart:async';

import 'package:flutter/material.dart' hide Image;

import 'draw_event.dart';

class _Stroke {
  final Path path;
  final Paint paint;

  _Stroke(this.path, this.paint);
}

class PlaybackController extends ChangeNotifier {
  final List<_Stroke> _strokes = [];
  Color _backgroundColor = Colors.white;
  bool _inStroke = false;
  StreamSubscription<DrawEvent>? _subscription;

  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  void listen(Stream<DrawEvent> events) {
    _subscription?.cancel();
    _subscription = events.listen(_handleEvent);
  }

  void applyEvent(DrawEvent event) => _handleEvent(event);

  void _handleEvent(DrawEvent event) {
    switch (event.type) {
      case DrawEventType.strokeStart:
        final paint = Paint()
          ..color = Color(event.color!)
          ..strokeWidth = event.thickness!
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        final path = Path()..moveTo(event.x!, event.y!);
        _strokes.add(_Stroke(path, paint));
        _inStroke = true;
      case DrawEventType.strokeUpdate:
        if (_inStroke && _strokes.isNotEmpty) {
          _strokes.last.path.lineTo(event.x!, event.y!);
        }
      case DrawEventType.strokeEnd:
        _inStroke = false;
      case DrawEventType.undo:
        if (_strokes.isNotEmpty && !_inStroke) {
          _strokes.removeLast();
        }
      case DrawEventType.clear:
        _strokes.clear();
        _inStroke = false;
    }
    notifyListeners();
  }

  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = _backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bg);

    for (final stroke in _strokes) {
      canvas.drawPath(stroke.path, stroke.paint);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class PlaybackPainter extends CustomPainter {
  final PlaybackController controller;

  PlaybackPainter(this.controller) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    controller.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PlaybackCanvas extends StatelessWidget {
  final PlaybackController controller;

  const PlaybackCanvas({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: PlaybackPainter(controller),
        willChange: true,
        child: const SizedBox.expand(),
      ),
    );
  }
}
