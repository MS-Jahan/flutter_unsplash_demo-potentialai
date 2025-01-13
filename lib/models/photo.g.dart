// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhotoAdapter extends TypeAdapter<Photo> {
  @override
  final int typeId = 0;

  @override
  Photo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Photo(
      id: fields[0] as String,
      description: fields[1] as String?,
      altDescription: fields[2] as String?,
      urls: (fields[3] as Map).cast<String, String>(),
      links: (fields[4] as Map).cast<String, String>(),
      color: fields[5] as String?,
      likes: fields[6] as int?,
      user: fields[7] as PhotoUser,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Photo obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.altDescription)
      ..writeByte(3)
      ..write(obj.urls)
      ..writeByte(4)
      ..write(obj.links)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.likes)
      ..writeByte(7)
      ..write(obj.user)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PhotoUserAdapter extends TypeAdapter<PhotoUser> {
  @override
  final int typeId = 1;

  @override
  PhotoUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhotoUser(
      id: fields[0] as String,
      username: fields[1] as String,
      name: fields[2] as String,
      profileImage: (fields[3] as Map?)?.cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PhotoUser obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.profileImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
