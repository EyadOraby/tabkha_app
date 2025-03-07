// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive_flutter/hive_flutter.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 0)
class UserPreferences {
  @HiveField(1)
  LanguageCodeEnum language;

  UserPreferences({
    required this.language,
  });

  UserPreferences copyWith({
    LanguageCodeEnum? language,
  }) {
    return UserPreferences(
      language: language ?? this.language,
    );
  }
}

@HiveType(typeId: 1)
enum AppMode {
  @HiveField(1)
  lightMode,
}

@HiveType(typeId: 2)
enum LanguageCodeEnum {
  @HiveField(0)
  en,
  @HiveField(1)
  ar;

  @override
  String toString() {
    switch (this) {
      case en:
        return "English";
      case ar:
        return "العربية";
    }
  }
}
