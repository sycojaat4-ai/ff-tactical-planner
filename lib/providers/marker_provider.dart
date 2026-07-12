import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:ff_tactical_planner/models/marker_model.dart';

/// Manages the full set of markers currently placed on the tactical board.
/// Uses ChangeNotifier so marker drags/rotations repaint only the listening
/// widgets (not the whole tree), keeping interactions at 60fps+.
class MarkerProvider extends ChangeNotifier {
  final List<MarkerModel> _markers = [];
  final _uuid = const Uuid();

  String? _selectedId;

  List<MarkerModel> get markers => List.unmodifiable(_markers);
  String? get selectedId => _selectedId;

  MarkerModel? get selected =>
      _markers.where((m) => m.id == _selectedId).cast<MarkerModel?>().firstOrNull;

  /// Places a new marker at normalized [dx],[dy] (0-1 relative to map image).
  MarkerModel addMarker(MarkerType type, double dx, double dy) {
    final marker = MarkerModel(id: _uuid.v4(), type: type, dx: dx, dy: dy);
    _markers.add(marker);
    _selectedId = marker.id;
    notifyListeners();
    return marker;
  }

  void select(String? id) {
    _selectedId = id;
    notifyListeners();
  }

  /// Moves a marker to a new normalized position. Called continuously during
  /// drag - kept lightweight (no list rebuild) for smooth 60fps dragging.
  void moveMarker(String id, double dx, double dy) {
    final m = _markers.firstWhere((e) => e.id == id);
    if (m.locked) return;
    m.dx = dx.clamp(0.0, 1.0);
    m.dy = dy.clamp(0.0, 1.0);
    notifyListeners();
  }

  void rotateMarker(String id, double rotation) {
    final m = _markers.firstWhere((e) => e.id == id);
    if (m.locked) return;
    m.rotation = rotation;
    notifyListeners();
  }

  void resizeMarker(String id, double scale) {
    final m = _markers.firstWhere((e) => e.id == id);
    if (m.locked) return;
    m.scale = scale.clamp(0.5, 3.0);
    notifyListeners();
  }

  void toggleLock(String id) {
    final m = _markers.firstWhere((e) => e.id == id);
    m.locked = !m.locked;
    notifyListeners();
  }

  void duplicateMarker(String id) {
    final m = _markers.firstWhere((e) => e.id == id);
    final copy = MarkerModel(
      id: _uuid.v4(),
      type: m.type,
      dx: (m.dx + 0.03).clamp(0.0, 1.0),
      dy: (m.dy + 0.03).clamp(0.0, 1.0),
      rotation: m.rotation,
      scale: m.scale,
      label: m.label,
    );
    _markers.add(copy);
    _selectedId = copy.id;
    notifyListeners();
  }

  void deleteMarker(String id) {
    _markers.removeWhere((e) => e.id == id);
    if (_selectedId == id) _selectedId = null;
    notifyListeners();
  }

  void clearAll() {
    _markers.clear();
    _selectedId = null;
    notifyListeners();
  }

  /// Replaces the whole marker set - used when loading a saved strategy.
  void loadMarkers(List<MarkerModel> loaded) {
    _markers
      ..clear()
      ..addAll(loaded);
    _selectedId = null;
    notifyListeners();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
