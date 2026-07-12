// GENERATED CODE - Hive TypeAdapters for StrategyModel
part of 'strategy_model.dart';

class GameMapAdapter extends TypeAdapter<GameMap> {
  @override
  final int typeId = 0;

  @override
  GameMap read(BinaryReader reader) => GameMap.values[reader.readByte()];

  @override
  void write(BinaryWriter writer, GameMap obj) => writer.writeByte(obj.index);
}

class StrategyModelAdapter extends TypeAdapter<StrategyModel> {
  @override
  final int typeId = 6;

  @override
  StrategyModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return StrategyModel(
      id: fields[0] as String,
      name: fields[1] as String,
      map: fields[2] as GameMap,
      markers: (fields[3] as List).cast<MarkerModel>(),
      drawings: (fields[4] as List).cast<DrawingStroke>(),
      updatedAt: fields[5] as DateTime,
      transformMatrix: (fields[6] as List?)?.cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, StrategyModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.map)
      ..writeByte(3)
      ..write(obj.markers)
      ..writeByte(4)
      ..write(obj.drawings)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.transformMatrix);
  }
}
