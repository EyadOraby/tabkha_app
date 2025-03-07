// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 0;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      language: fields[1] as LanguageCodeEnum,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(1)
      ..writeByte(1)
      ..write(obj.language);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppModeAdapter extends TypeAdapter<AppMode> {
  @override
  final int typeId = 1;

  @override
  AppMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return AppMode.lightMode;
      default:
        return AppMode.lightMode;
    }
  }

  @override
  void write(BinaryWriter writer, AppMode obj) {
    switch (obj) {
      case AppMode.lightMode:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LanguageCodeEnumAdapter extends TypeAdapter<LanguageCodeEnum> {
  @override
  final int typeId = 2;

  @override
  LanguageCodeEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LanguageCodeEnum.en;
      case 1:
        return LanguageCodeEnum.ar;
      default:
        return LanguageCodeEnum.en;
    }
  }

  @override
  void write(BinaryWriter writer, LanguageCodeEnum obj) {
    switch (obj) {
      case LanguageCodeEnum.en:
        writer.writeByte(0);
        break;
      case LanguageCodeEnum.ar:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageCodeEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
