import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ff_tactical_planner/models/drawing_model.dart';
import 'package:ff_tactical_planner/providers/drawing_provider.dart';

/// A transparent overlay, sized exactly to the map image, that captures
/// finger input for all drawing tools and renders every stroke via
/// CustomPainter. Normalized (0-1) point storage means strokes stay
/// pixel-accurate at any zoom level.
class DrawingCanvas extends StatelessWidget {
  final Size mapSize;
  const DrawingCanvas({super.key, required this.mapSize});

  Offset _toNorm(Offset local) {
    return Offset(
      (local.dx / mapSize.width).clamp(0.0, 1.0),
      (local.dy / mapSize.height).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawing = context.watch<DrawingProvider>();

    return SizedBox(
      width: mapSize.width,
      height: mapSize.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: drawing.drawingEnabled
            ? (details) => drawing.startStroke(_toNorm(details.localPosition))
            : null,
        onPanUpdate: drawing.drawingEnabled
            ? (details) => drawing.extendStroke(_toNorm(details.localPosition))
            : null,
        onPanEnd: drawing.drawingEnabled ? (_) => drawing.endStroke() : null,
        child: RepaintBoundary(
          child: CustomPaint(
            size: mapSize,
            painter: _StrokesPainter(
              strokes: drawing.strokes,
              inProgress: drawing.inProgress,
              mapSize: mapSize,
            ),
            isComplex: true,
            willChange: drawing.drawingEnabled,
          ),
        ),
      ),
    );
  }
}

class _StrokesPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? inProgress;
  final Size mapSize;

  _StrokesPainter({
    required this.strokes,
    required this.inProgress,
    required this.mapSize,
  });

  Offset _denorm(NormPoint p) => Offset(p.dx * mapSize.width, p.dy * mapSize.height);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _paintStroke(canvas, stroke);
    }
    if (inProgress != null) {
      _paintStroke(canvas, inProgress!);
    }
  }

  void _paintStroke(Canvas canvas, DrawingStroke stroke) {
    final paint = Paint()
      ..color = Color(stroke.colorValue)
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.points.isEmpty) return;

    switch (stroke.tool) {
      case DrawTool.freehand:
        final path = Path()..moveTo(_denorm(stroke.points.first).dx, _denorm(stroke.points.first).dy);
        for (final p in stroke.points.skip(1)) {
          final o = _denorm(p);
          path.lineTo(o.dx, o.dy);
        }
        canvas.drawPath(path, paint);
        break;

      case DrawTool.line:
        if (stroke.points.length < 2) return;
        canvas.drawLine(_denorm(stroke.points[0]), _denorm(stroke.points[1]), paint);
        break;

      case DrawTool.arrow:
        if (stroke.points.length < 2) return;
        _drawArrow(canvas, _denorm(stroke.points[0]), _denorm(stroke.points[1]), paint);
        break;

      case DrawTool.circle:
        if (stroke.points.length < 2) return;
        final start = _denorm(stroke.points[0]);
        final end = _denorm(stroke.points[1]);
        final radius = (end - start).distance;
        canvas.drawCircle(start, radius, paint);
        break;

      case DrawTool.rectangle:
        if (stroke.points.length < 2) return;
        final start = _denorm(stroke.points[0]);
        final end = _denorm(stroke.points[1]);
        canvas.drawRect(Rect.fromPoints(start, end), paint);
        break;
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);
    const arrowLength = 18.0;
    const arrowAngle = 0.5; // radians
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);

    final p1 = Offset(
      end.dx - arrowLength * math.cos(angle - arrowAngle),
      end.dy - arrowLength * math.sin(angle - arrowAngle),
    );
    final p2 = Offset(
      end.dx - arrowLength * math.cos(angle + arrowAngle),
      end.dy - arrowLength * math.sin(angle + arrowAngle),
    );

    final headPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    final headPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(headPath, headPaint);
  }

  @override
  bool shouldRepaint(covariant _StrokesPainter oldDelegate) {
    return oldDelegate.strokes != strokes || oldDelegate.inProgress != inProgress;
  }
}
