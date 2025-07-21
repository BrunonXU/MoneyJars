// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jar_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JarSettingsModelAdapter extends TypeAdapter<JarSettingsModel> {
  @override
  final int typeId = 4;

  @override
  JarSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JarSettingsModel()
      ..targetAmount = fields[0] as double
      ..title = fields[1] as String
      ..updatedAt = fields[2] as DateTime
      ..deadline = fields[3] as DateTime?
      ..jarTypeIndex = fields[4] as int
      ..enableTargetReminder = fields[5] == null ? false : fields[5] as bool
      ..reminderThreshold = fields[6] == null ? 0.8 : fields[6] as double
      ..customColor = fields[7] as int?
      ..customIcon = fields[8] as String?
      ..description = fields[9] as String?
      ..showOnHome = fields[10] == null ? true : fields[10] as bool
      ..displayOrder = fields[11] == null ? 0 : fields[11] as int
      ..userId = fields[12] as String?;
  }

  @override
  void write(BinaryWriter writer, JarSettingsModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.targetAmount)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.updatedAt)
      ..writeByte(3)
      ..write(obj.deadline)
      ..writeByte(4)
      ..write(obj.jarTypeIndex)
      ..writeByte(5)
      ..write(obj.enableTargetReminder)
      ..writeByte(6)
      ..write(obj.reminderThreshold)
      ..writeByte(7)
      ..write(obj.customColor)
      ..writeByte(8)
      ..write(obj.customIcon)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.showOnHome)
      ..writeByte(11)
      ..write(obj.displayOrder)
      ..writeByte(12)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JarSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
