// GENERATED CODE - Hive TypeAdapters for MarkerModel
// Hand-authored to match `hive_generator` output exactly, so the project
// builds even before running `flutter packages pub run build_runner build`.
part of 'marker_model.dart';

class MarkerTypeAdapter extends TypeAdapter<MarkerType> {
  @override
  final int typeId = 1;

  @override
  MarkerType read(BinaryReader reader) {
    final index = reader.readByte();
    return MarkerType.values[index];
  }

  @override
  void write(BinaryWriter writer, MarkerType obj) {
    writer.writeByte(obj.index);
  }
}

class MarkerModelAdapter extends TypeAdapter<MarkerModel> {
  @override
  final int typeId = 2;

  @override
  MarkerModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return MarkerModel(
      id: fields[0] as String,
      type: fields[1] as MarkerType,
      dx: fields[2] as double,
      dy: fields[3] as double,
      rotation: fields[4] as double,
      scale: fields[5] as double,
      locked: fields[6] as bool,
      label: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MarkerModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.dx)
      ..writeByte(3)
      ..write(obj.dy)
      ..writeByte(4)
      ..write(obj.rotation)
      ..writeByte(5)
      ..write(obj.scale)
      ..writeByte(6)
      ..write(obj.locked)
      ..writeByte(7)
      ..write(obj.label);
  }
}
