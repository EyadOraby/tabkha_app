import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tabkha_app/Services/caching_service.dart';
import 'package:tabkha_app/commonModels/user_preferences.dart';

part 'preferences_service.g.dart';

@Riverpod(keepAlive: true)
class PreferencesState extends _$PreferencesState {
  late CachingService _cachingService;
  @override
  UserPreferences build() {
    UserPreferences? preferences;
    _cachingService = ref.watch(cachingServiceProvider);
    preferences = _cachingService.get(userPreferences);
    preferences ??= UserPreferences(
      language: LanguageCodeEnum.en,
    );
    return preferences;
  }

  void updatePreferences({
    AppMode? appMode,
    LanguageCodeEnum? languageCodeEnum,
  }) {
    state = state.copyWith(language: languageCodeEnum);

    _cachingService.put(userPreferences, state);
  }
}
