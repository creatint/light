import 'dart:async';
import 'package:flutter/foundation.dart' show required;
import 'package:shared_preferences/shared_preferences.dart';

class SystemService {
  static SystemService _cache;

  SystemService._internal({@required this.prefs})
      : streamController = new StreamController<dynamic>.broadcast();

  factory SystemService({SharedPreferences prefs}) {
    if (null == _cache) {
      _cache = new SystemService._internal(prefs: prefs);
    }
    return _cache;
  }

  /// SharedPreferences实例
  final SharedPreferences prefs;

  /// controller of stream
  final StreamController<dynamic> streamController;

  /// get stream
  Stream get stream => streamController.stream;

  /// fire a event
  void addEvent(value) => streamController.add(value);
}