import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:ff_tactical_planner/models/drawing_model.dart';
import 'package:ff_tactical_planner/utils/constants.dart';

/// Manages all completed drawing strokes plus the in-progress stroke, with
/// full undo/redo history. The in-progress stroke is isolated from
/// `strokes` so live drawing repaints don't invalidate the undo stack.
class DrawingProvider extends ChangeNotifier {
  final List<DrawingStroke> _strokes = [];
  final List<List<DrawingStroke>> _undoStack = [];
  final List<List<DrawingStroke>> _redoStack = [];
  final _uuid = const Uuid();

  DrawTool _activeTool = DrawTool.freehand;
  Color _activeColor = kDrawColors.first;
  double _activeWidth = 4.0;
  bool _drawingEnabled = false;

  DrawingStroke? _inProgress;

  List<DrawingStroke> get strokes => List.unmodifiable(_strokes);
  DrawingStroke? get inProgress => _inProgress;
  DrawTool get activeTool => _activeTool;
  Color get activeColor => _activeColor;
  double get activeWidth => _activeWidth;
  bool get drawingEnabled => _drawingEnabled;

  void setTool(DrawTool tool) {
    _activeTool = tool;
    notifyListeners();
  }

  void setColor(Color color) {
    _activeColor = color;
    notifyListeners();
  }

  void setWidth(double width) {
    _activeWidth = width;
    notifyListeners();
  }

  void toggleDrawingMode([bool? value]) {
    _drawingEnabled = value ?? !_drawingEnabled;
    notifyListeners();
  }

  void _pushHistory() {
    _undoStack.add(_strokes.map((s) => s).toList());
    _redoStack.clear();
  }

  void startStroke(Offset normPoint) {
    _inProgress = DrawingStroke(
      id: _uuid.v4(),
      tool: _activeTool,
      points: [NormPoint(normPoint.dx, normPoint.dy)],
      colorValue: _activeColor.value,
      strokeWidth: _activeWidth,
    );
    notifyListeners();
  }

  void extendStroke(Offset normPoint) {
    if (_inProgress == null) return;
    if (_activeTool == DrawTool.freehand) {
      _inProgress!.points.add(NormPoint(normPoint.dx, normPoint.dy));
    } else {
      // line / arrow / circle / rectangle only need start + live end point
      if (_inProgress!.points.length == 1) {
        _inProgress!.points.add(NormPoint(normPoint.dx, normPoint.dy));
      } else {
        _inProgress!.points[1] = NormPoint(normPoint.dx, normPoint.dy);
      }
    }
    notifyListeners();
  }

  void endStroke() {
    if (_inProgress == null) return;
    _pushHistory();
    _strokes.add(_inProgress!);
    _inProgress = null;
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_strokes.map((s) => s).toList());
    final prev = _undoStack.removeLast();
    _strokes
      ..clear()
      ..addAll(prev);
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_strokes.map((s) => s).toList());
    final next = _redoStack.removeLast();
    _strokes
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  void clearAll() {
    _pushHistory();
    _strokes.clear();
    notifyListeners();
  }

  void loadStrokes(List<DrawingStroke> loaded) {
    _strokes
      ..clear()
      ..addAll(loaded);
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }
}
