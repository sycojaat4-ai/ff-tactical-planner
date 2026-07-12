// GENERATED CODE - Hive TypeAdapters for DrawingStroke
part of 'drawing_model.dart';

class DrawToolAdapter extends TypeAdapter<DrawTool> {
  @override
  final int typeId = 3;

  @override
  DrawTool read(BinaryReader reader) => DrawTool.values[reader.readByte()];

  @override
  void write(BinaryWriter writer, DrawTool obj) => writer.writeByte(obj.index);
}

class NormPointAdapter extends TypeAdapter<NormPoint> {
  @override
  final int typeId = 4;

  @override
  NormPoint read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return NormPoint(fields[0] as double, fields[1] as double);
  }

  @override
  void write(BinaryWriter writer, NormPoint obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.dx)
      ..writeByte(1)
      ..write(obj.dy);
  }
}

class DrawingStrokeAdapter extends TypeAdapter<DrawingStroke> {
  @override
  final int typeId = 5;

  @override
  DrawingStroke read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return DrawingStroke(
      id: fields[0] as String,
      tool: fields[1] as DrawTool,
      points: (fields[2] as List).cast<NormPoint>(),
      colorValue: fields[3] as int,
      strokeWidth: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DrawingStroke obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tool)
      ..writeByte(2)
      ..write(obj.points)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.strokeWidth);
  }
}
