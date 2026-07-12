import 'package:hive/hive.dart';

part 'marker_model.g.dart';

/// All marker categories available in the bottom toolbar.
/// Grouped as: Utility (map objects), Player roles, Tactical callouts.
@HiveType(typeId: 1)
enum MarkerType {
  @HiveField(0)
  vendingMachine,
  @HiveField(1)
  coinMachine,
  @HiveField(2)
  launchPad,
  @HiveField(3)
  arsenal,
  @HiveField(4)
  zipline,
  @HiveField(5)
  rusher1,
  @HiveField(6)
  rusher2,
  @HiveField(7)
  assaulter,
  @HiveField(8)
  sniper,
  @HiveField(9)
  waypoint,
  @HiveField(10)
  enemy,
  @HiveField(11)
  safePosition,
  @HiveField(12)
  danger,
  @HiveField(13)
  vehicle,
  @HiveField(14)
  camp,
  @HiveField(15)
  loot,
  @HiveField(16)
  rotationArrow,
}

/// A single tactical marker placed on the map.
/// Stores normalized (0-1) coordinates relative to the *original* map image
/// so that markers stay pixel-perfect at any zoom level or screen size.
@HiveType(typeId: 2)
class MarkerModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  MarkerType type;

  /// Normalized X position (0.0 - 1.0) relative to map image width.
  @HiveField(2)
  double dx;

  /// Normalized Y position (0.0 - 1.0) relative to map image height.
  @HiveField(3)
  double dy;

  @HiveField(4)
  double rotation; // radians

  @HiveField(5)
  double scale; // 1.0 = default size

  @HiveField(6)
  bool locked;

  @HiveField(7)
  String? label; // optional custom text (e.g. "Rush A")

  MarkerModel({
    required this.id,
    required this.type,
    required this.dx,
    required this.dy,
    this.rotation = 0.0,
    this.scale = 1.0,
    this.locked = false,
    this.label,
  });

  MarkerModel copyWith({
    double? dx,
    double? dy,
    double? rotation,
    double? scale,
    bool? locked,
    String? label,
  }) {
    return MarkerModel(
      id: id,
      type: type,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      locked: locked ?? this.locked,
      label: label ?? this.label,
    );
  }
}
