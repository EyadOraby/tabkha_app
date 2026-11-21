// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PreferencesState)
final preferencesStateProvider = PreferencesStateProvider._();

final class PreferencesStateProvider
    extends $NotifierProvider<PreferencesState, UserPreferences> {
  PreferencesStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'preferencesStateProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$preferencesStateHash();

  @$internal
  @override
  PreferencesState create() => PreferencesState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserPreferences>(value),
    );
  }
}

String _$preferencesStateHash() => r'376817ab58c39e48db4901b5a46201468791e98f';

abstract class _$PreferencesState extends $Notifier<UserPreferences> {
  UserPreferences build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UserPreferences, UserPreferences>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<UserPreferences, UserPreferences>,
        UserPreferences,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
