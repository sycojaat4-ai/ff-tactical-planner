import 'package:hive/hive.dart';
import 'marker_model.dart';
import 'drawing_model.dart';

part 'strategy_model.g.dart';

/// The 5 official maps bundled with the app. Each entry points at the
/// untouched, full-resolution asset supplied by the user.
@HiveType(typeId: 0)
enum GameMap {
  @HiveField(0)
  bermuda,
  @HiveField(1)
  kalahari,
  @HiveField(2)
  nextera,
  @HiveField(3)
  purgatory,
  @HiveField(4)
  solara,
}

extension GameMapAsset on GameMap {
  String get assetPath {
    switch (this) {
      case GameMap.bermuda:
        return 'assets/maps/map_bermuda.jpg';
      case GameMap.kalahari:
        return 'assets/maps/map_kalahari.png';
      case GameMap.nextera:
        return 'assets/maps/map_nextera.jpg';
      case GameMap.purgatory:
        return 'assets/maps/map_purgatory.jpg';
      case GameMap.solara:
        return 'assets/maps/map_solara.jpg';
    }
  }

  String get displayName {
    switch (this) {
      case GameMap.bermuda:
        return 'Bermuda';
      case GameMap.kalahari:
        return 'Kalahari';
      case GameMap.nextera:
        return 'NeXTerra';
      case GameMap.purgatory:
        return 'Purgatory';
      case GameMap.solara:
        return 'Solara';
    }
  }
}

/// A full saved strategy: which map, every marker, every drawing stroke,
/// and the last camera (zoom/pan) transform so re-opening a strategy
/// restores the board exactly as the user left it.
@HiveType(typeId: 6)
class StrategyModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  GameMap map;

  @HiveField(3)
  List<MarkerModel> markers;

  @HiveField(4)
  List<DrawingStroke> drawings;

  @HiveField(5)
  DateTime updatedAt;

  /// Flattened 4x4 InteractiveViewer transform matrix (16 doubles),
  /// stored so zoom/pan state is remembered exactly.
  @HiveField(6)
  List<double>? transformMatrix;

  StrategyModel({
    required this.id,
    required this.name,
    required this.map,
    required this.markers,
    required this.drawings,
    required this.updatedAt,
    this.transformMatrix,
  });
}
