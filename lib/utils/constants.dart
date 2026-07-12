import 'package:flutter/material.dart';
import 'package:ff_tactical_planner/models/marker_model.dart';

/// Dark esports color palette used throughout the app.
class AppColors {
  static const bg = Color(0xFF0A0E14);
  static const surface = Color(0xFF141A24);
  static const surfaceGlass = Color(0x99141A24); // glassmorphism panels
  static const accent = Color(0xFF00E5FF); // cyan esports accent
  static const accentSecondary = Color(0xFFFF3D6E); // hot pink accent
  static const gold = Color(0xFFFFC72C);
  static const textPrimary = Color(0xFFEAF0FA);
  static const textSecondary = Color(0xFF8C97AD);
  static const border = Color(0x33FFFFFF);

  static const rusher1 = Color(0xFFFF3B30); // red
  static const rusher2 = Color(0xFF2E86FF); // blue
  static const assaulter = Color(0xFF2ED573); // green
  static const sniper = Color(0xFFB24BF3); // purple
}

/// Maps each MarkerType to its icon + accent color + short label used in
/// the toolbar, the on-map chip, and the marker inspector.
class MarkerStyle {
  final IconData icon;
  final Color color;
  final String label;
  const MarkerStyle(this.icon, this.color, this.label);
}

const Map<MarkerType, MarkerStyle> kMarkerStyles = {
  MarkerType.vendingMachine:
      MarkerStyle(Icons.local_drink_rounded, AppColors.gold, 'Vending'),
  MarkerType.coinMachine:
      MarkerStyle(Icons.monetization_on_rounded, AppColors.gold, 'Coin'),
  MarkerType.launchPad:
      MarkerStyle(Icons.rocket_launch_rounded, AppColors.accent, 'Launch Pad'),
  MarkerType.arsenal:
      MarkerStyle(Icons.gavel_rounded, AppColors.accent, 'Arsenal'),
  MarkerType.zipline:
      MarkerStyle(Icons.cable_rounded, AppColors.accent, 'Zipline'),
  MarkerType.rusher1:
      MarkerStyle(Icons.person_pin_circle_rounded, AppColors.rusher1, 'Rusher 1'),
  MarkerType.rusher2:
      MarkerStyle(Icons.person_pin_circle_rounded, AppColors.rusher2, 'Rusher 2'),
  MarkerType.assaulter:
      MarkerStyle(Icons.person_pin_circle_rounded, AppColors.assaulter, 'Assaulter'),
  MarkerType.sniper:
      MarkerStyle(Icons.person_pin_circle_rounded, AppColors.sniper, 'Sniper'),
  MarkerType.waypoint:
      MarkerStyle(Icons.flag_rounded, AppColors.accent, 'Waypoint'),
  MarkerType.enemy:
      MarkerStyle(Icons.dangerous_rounded, AppColors.accentSecondary, 'Enemy'),
  MarkerType.safePosition:
      MarkerStyle(Icons.shield_rounded, AppColors.assaulter, 'Safe Position'),
  MarkerType.danger:
      MarkerStyle(Icons.warning_rounded, AppColors.gold, 'Danger'),
  MarkerType.vehicle:
      MarkerStyle(Icons.directions_car_filled_rounded, AppColors.textPrimary, 'Vehicle'),
  MarkerType.camp:
      MarkerStyle(Icons.cabin_rounded, AppColors.textPrimary, 'Camp'),
  MarkerType.loot:
      MarkerStyle(Icons.backpack_rounded, AppColors.gold, 'Loot'),
  MarkerType.rotationArrow:
      MarkerStyle(Icons.turn_slight_right_rounded, AppColors.accentSecondary, 'Rotation'),
};

/// Palette offered by the drawing tool color picker.
const List<Color> kDrawColors = [
  AppColors.accentSecondary,
  AppColors.accent,
  AppColors.gold,
  AppColors.assaulter,
  Colors.white,
  AppColors.rusher2,
];

const double kMarkerBaseSize = 40.0;
const double kMinScale = 0.9;
const double kMaxScale = 5.0;
