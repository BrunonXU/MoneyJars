// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 1;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel()
      ..id = fields[0] as String
      ..amount = fields[1] as double
      ..description = fields[2] as String
      ..parentCategoryId = fields[3] as String
      ..parentCategoryName = fields[4] as String
      ..subCategoryId = fields[5] as String?
      ..subCategoryName = fields[6] as String?
      ..typeIndex = fields[7] as int
      ..date = fields[8] as DateTime
      ..isArchived = fields[9] == null ? false : fields[9] as bool
      ..createdAt = fields[10] as DateTime
      ..updatedAt = fields[11] as DateTime
      ..notes = fields[12] as String?
      ..tags = (fields[13] as List?)?.cast<String>()
      ..userId = fields[14] as String?
      ..deviceId = fields[15] as String?
      ..syncedAt = fields[16] as DateTime?
      ..metadata = fields[17] as String?;
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.parentCategoryId)
      ..writeByte(4)
      ..write(obj.parentCategoryName)
      ..writeByte(5)
      ..write(obj.subCategoryId)
      ..writeByte(6)
      ..write(obj.subCategoryName)
      ..writeByte(7)
      ..write(obj.typeIndex)
      ..writeByte(8)
      ..write(obj.date)
      ..writeByte(9)
      ..write(obj.isArchived)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.tags)
      ..writeByte(14)
      ..write(obj.userId)
      ..writeByte(15)
      ..write(obj.deviceId)
      ..writeByte(16)
      ..write(obj.syncedAt)
      ..writeByte(17)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
