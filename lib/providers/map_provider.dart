import 'package:flutter/material.dart';
import 'package:ff_tactical_planner/models/strategy_model.dart';

/// Holds which map is active and the InteractiveViewer's TransformationController,
/// so zoom/pan state can be captured and restored per saved strategy.
class MapProvider extends ChangeNotifier {
  GameMap _activeMap = GameMap.bermuda;
  final TransformationController transformController = TransformationController();

  GameMap get activeMap => _activeMap;

  void setMap(GameMap map) {
    _activeMap = map;
    transformController.value = Matrix4.identity();
    notifyListeners();
  }

  void restoreTransform(List<double>? matrixValues) {
    if (matrixValues == null || matrixValues.length != 16) {
      transformController.value = Matrix4.identity();
      return;
    }
    transformController.value = Matrix4.fromList(matrixValues);
  }

  List<double> captureTransform() {
    return transformController.value.storage.toList();
  }

  void resetView() {
    transformController.value = Matrix4.identity();
    notifyListeners();
  }

  @override
  void dispose() {
    transformController.dispose();
    super.dispose();
  }
}
