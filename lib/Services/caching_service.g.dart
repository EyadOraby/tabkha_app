// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caching_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cachingService)
final cachingServiceProvider = CachingServiceProvider._();

final class CachingServiceProvider
    extends $FunctionalProvider<CachingService, CachingService, CachingService>
    with $Provider<CachingService> {
  CachingServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cachingServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cachingServiceHash();

  @$internal
  @override
  $ProviderElement<CachingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CachingService create(Ref ref) {
    return cachingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CachingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CachingService>(value),
    );
  }
}

String _$cachingServiceHash() => r'a646f97efa224a47ca7da8637b50cee0d9d1be50';
