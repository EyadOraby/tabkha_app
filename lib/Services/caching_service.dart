import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'caching_service.g.dart';

const String userPreferences = "PREFERENCES";

class CachingService {
  late Box box;
  CachingService() {
    box = Hive.box(userPreferences);
  }
  Future<void> put(String key, dynamic value) => box.put(key, value);
  Future<void> delete(String key) => box.delete(key);
  dynamic get(String key) => box.get(key);

  bool containsKey(String key) => box.containsKey(key);
}

@Riverpod(keepAlive: true)
CachingService cachingService(CachingServiceRef ref) {
  ref.onDispose(() => Hive.box(userPreferences).close());
  return CachingService();
}
