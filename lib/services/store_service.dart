import 'package:hive/hive.dart';
import 'package:song_manager/services/store_service.dart';

abstract class StoreService extends StoreServiceBase {
  StoreService();
  double get fontSize;
  Future<void> setFontSize(double value);
}

class MusStoreService extends StoreService {
  late Box box;
  MusStoreService(this.box);

  @override
  double get fontSize => box.get('font_size', defaultValue: 20.0);

  @override
  Future<void> setFontSize(double value) => box.put('font_size', value);

  @override
  E? get<E>(String key) {
    return box.get(key);
  }

  @override
  bool containsKey(dynamic key) {
    return box.containsKey(key);
  }

  @override
  Future<void> put(dynamic key, dynamic value) {
    return box.put(key, value);
  }

  @override
  Future<void> delete(dynamic key) {
    return box.delete(key);
  }
}

class TestStoreService extends StoreService {
  /// This is a test store service that does not use Hive.
  TestStoreService() : super();

  @override
  double get fontSize => 20;

  @override
  Future<void> setFontSize(double value) => Future.value();

  @override
  E? get<E>(String key) {
    return null;
  }

  @override
  bool containsKey(dynamic key) {
    return false;
  }

  @override
  Future<void> put(dynamic key, dynamic value) {
    return Future.value();
  }

  @override
  Future<void> delete(dynamic key) {
    return Future.value();
  }
}
