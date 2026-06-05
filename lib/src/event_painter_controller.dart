import 'dart:async';

import 'package:flutter/material.dart' hide Image;

import 'draw_event.dart';

class _Stroke {
  final Path path;
  final Paint paint;

  _Stroke(this.path, this.paint);
}

class EventPainterController extends ChangeNotifier {
  final List<_Stroke> _strokes = [];
  final List<DrawEvent> _eventLog = [];
  final StreamController<DrawEvent> _eventStream =
      StreamController<DrawEvent>.broadcast();

  Color _drawColor = Colors.black;
  double _thickness = 5.0;
  Color _backgroundColor = Colors.white;
  bool _inDrag = false;

  Stream<DrawEvent> get events => _eventStream.stream;
  List<DrawEvent> get eventLog => List.unmodifiable(_eventLog);

  Color get drawColor => _drawColor;
  set drawColor(Color color) {
    _drawColor = color;
  }

  double get thickness => _thickness;
  set thickness(double t) {
    _thickness = t;
  }

  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  void onPanStart(Offset position) {
    if (_inDrag) return;
    _inDrag = true;

    final paint = Paint()
      ..color = _drawColor
      ..strokeWidth = _thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(position.dx, position.dy);
    _strokes.add(_Stroke(path, paint));

    final event = DrawEvent.strokeStart(
      x: position.dx,
      y: position.dy,
      color: _drawColor.toARGB32(),
      thickness: _thickness,
    );
    _eventLog.add(event);
    _eventStream.add(event);
    notifyListeners();
  }

  void onPanUpdate(Offset position) {
    if (!_inDrag) return;

    _strokes.last.path.lineTo(position.dx, position.dy);

    final event = DrawEvent.strokeUpdate(x: position.dx, y: position.dy);
    _eventLog.add(event);
    _eventStream.add(event);
    notifyListeners();
  }

  void onPanEnd() {
    if (!_inDrag) return;
    _inDrag = false;

    final event = DrawEvent.strokeEnd();
    _eventLog.add(event);
    _eventStream.add(event);
    notifyListeners();
  }

  void undo() {
    if (_strokes.isEmpty || _inDrag) return;
    _strokes.removeLast();

    final event = DrawEvent.undo();
    _eventLog.add(event);
    _eventStream.add(event);
    notifyListeners();
  }

  void clear() {
    if (_inDrag) return;
    _strokes.clear();

    final event = DrawEvent.clear();
    _eventLog.add(event);
    _eventStream.add(event);
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
    _eventStream.close();
    super.dispose();
  }
}

class EventPainter extends CustomPainter {
  final EventPainterController controller;

  EventPainter(this.controller) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    controller.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawCanvas extends StatelessWidget {
  final EventPainterController controller;

  const DrawCanvas({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        final box = context.findRenderObject() as RenderBox;
        controller.onPanStart(box.globalToLocal(details.globalPosition));
      },
      onPanUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        controller.onPanUpdate(box.globalToLocal(details.globalPosition));
      },
      onPanEnd: (_) => controller.onPanEnd(),
      child: ClipRect(
        child: CustomPaint(
          painter: EventPainter(controller),
          willChange: true,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
