import 'package:hive/hive.dart';

part 'drawing_model.g.dart';

@HiveType(typeId: 3)
enum DrawTool {
  @HiveField(0)
  freehand,
  @HiveField(1)
  line,
  @HiveField(2)
  arrow,
  @HiveField(3)
  circle,
  @HiveField(4)
  rectangle,
}

/// A stored point, normalized (0-1) relative to the map image so drawings
/// remain accurate across zoom levels and screen sizes.
@HiveType(typeId: 4)
class NormPoint {
  @HiveField(0)
  double dx;
  @HiveField(1)
  double dy;

  NormPoint(this.dx, this.dy);
}

/// A single completed drawing stroke/shape on the tactical board.
@HiveType(typeId: 5)
class DrawingStroke extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DrawTool tool;

  /// For freehand + line: full point path.
  /// For circle/rectangle/arrow: [start, end] only (2 points).
  @HiveField(2)
  List<NormPoint> points;

  @HiveField(3)
  int colorValue; // Color.value

  @HiveField(4)
  double strokeWidth;

  DrawingStroke({
    required this.id,
    required this.tool,
    required this.points,
    required this.colorValue,
    this.strokeWidth = 4.0,
  });
}
