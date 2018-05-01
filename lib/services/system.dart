import 'dart:async';
import 'package:flutter/foundation.dart'
    show required, TargetPlatform, defaultTargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';

class SystemService {
  static SystemService _cache;

  SystemService._internal({@required this.prefs})
      : streamController = new StreamController<dynamic>.broadcast(),
        platform = defaultTargetPlatform;

  factory SystemService({SharedPreferences prefs}) {
    if (null == _cache) {
      _cache = new SystemService._internal(prefs: prefs);
    }
    return _cache;
  }

  /// SharedPreferences instance
  final SharedPreferences prefs;

  dynamic get(String key) => prefs.get(key);

  String getString(String key) => prefs.getString(key);

  List<String> getStringList(String key) => prefs.getStringList(key);

  double getDouble(String key) => prefs.getDouble(key);

  int getInt(String key) => prefs.getInt(key);

  bool getBool(String key) => prefs.getBool(key);

  Set<String> getKeys() => prefs.getKeys();

  void setString(String key, String value) => prefs.setString(key, value);

  void setDouble(String key, double value) => prefs.setDouble(key, value);

  void setInt(String key, int value) => prefs.setInt(key, value);

  void setBool(String key, bool value) => prefs.setBool(key, value);

  void setStringList(String key, List<String> value) =>
      prefs.setStringList(key, value);

  /// controller of stream
  final StreamController<dynamic> streamController;

  /// get stream
  Stream get stream => streamController.stream;

  /// fire a event
  /// value = [String eventName, dynamic data]
  void send(value) => streamController.add(value);

  /// add listener and return subscription
  StreamSubscription<T> listen<T>(void onData(T event)) {
    return stream.listen(onData);
  }

  /// device's platform
  final TargetPlatform platform;
}
