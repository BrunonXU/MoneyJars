// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 2;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryModel()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..typeIndex = fields[2] as int
      ..color = fields[3] as int
      ..icon = fields[4] as String
      ..subCategories = (fields[5] as List).cast<SubCategoryModel>()
      ..createdAt = fields[6] as DateTime
      ..updatedAt = fields[7] as DateTime
      ..isSystem = fields[8] == null ? false : fields[8] as bool
      ..isEnabled = fields[9] == null ? true : fields[9] as bool
      ..usageCount = fields[10] == null ? 0 : fields[10] as int
      ..userId = fields[11] as String?;
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.typeIndex)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.subCategories)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.isSystem)
      ..writeByte(9)
      ..write(obj.isEnabled)
      ..writeByte(10)
      ..write(obj.usageCount)
      ..writeByte(11)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubCategoryModelAdapter extends TypeAdapter<SubCategoryModel> {
  @override
  final int typeId = 3;

  @override
  SubCategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubCategoryModel()
      ..name = fields[0] as String
      ..icon = fields[1] as String
      ..usageCount = fields[2] == null ? 0 : fields[2] as int
      ..isEnabled = fields[3] == null ? true : fields[3] as bool;
  }

  @override
  void write(BinaryWriter writer, SubCategoryModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.icon)
      ..writeByte(2)
      ..write(obj.usageCount)
      ..writeByte(3)
      ..write(obj.isEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubCategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
