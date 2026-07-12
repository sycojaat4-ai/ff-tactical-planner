import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:ff_tactical_planner/models/strategy_model.dart';
import 'package:ff_tactical_planner/models/marker_model.dart';
import 'package:ff_tactical_planner/models/drawing_model.dart';

/// All local persistence for saved strategies. Uses Hive (fast, binary,
/// no native SQL dependency) so save/load is effectively instant even
/// with many markers and drawing strokes.
class StorageService {
  static const _boxName = 'strategies';
  static final _uuid = Uuid();

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(GameMapAdapter());
    Hive.registerAdapter(MarkerTypeAdapter());
    Hive.registerAdapter(MarkerModelAdapter());
    Hive.registerAdapter(DrawToolAdapter());
    Hive.registerAdapter(NormPointAdapter());
    Hive.registerAdapter(DrawingStrokeAdapter());
    Hive.registerAdapter(StrategyModelAdapter());

    await Hive.openBox<StrategyModel>(_boxName);
  }

  static Box<StrategyModel> get _box => Hive.box<StrategyModel>(_boxName);

  static List<StrategyModel> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Creates a brand-new strategy record and returns it.
  static Future<StrategyModel> create({
    required String name,
    required GameMap map,
  }) async {
    final strategy = StrategyModel(
      id: _uuid.v4(),
      name: name,
      map: map,
      markers: [],
      drawings: [],
      updatedAt: DateTime.now(),
    );
    await _box.put(strategy.id, strategy);
    return strategy;
  }

  /// Persists the current board state (markers, drawings, camera transform)
  /// into an existing strategy record.
  static Future<void> save({
    required String id,
    required List<MarkerModel> markers,
    required List<DrawingStroke> drawings,
    required List<double> transformMatrix,
  }) async {
    final existing = _box.get(id);
    if (existing == null) return;
    existing.markers = markers;
    existing.drawings = drawings;
    existing.transformMatrix = transformMatrix;
    existing.updatedAt = DateTime.now();
    await existing.save();
  }

  static Future<void> rename(String id, String newName) async {
    final existing = _box.get(id);
    if (existing == null) return;
    existing.name = newName;
    await existing.save();
  }

  static Future<void> delete(String id) async {
    await _box.delete(id);
  }

  static StrategyModel? getById(String id) => _box.get(id);
}
