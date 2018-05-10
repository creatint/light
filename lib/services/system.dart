import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart' show required;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'book.dart';
import 'file.dart';

class SystemService {
  static SystemService _cache;

  SystemService._internal({@required SharedPreferences prefs})
      : assert(null != prefs),
        _prefs = prefs,
        _streamController = new StreamController<dynamic>.broadcast();

  factory SystemService({SharedPreferences prefs}) {
    if (null == _cache) {
      print('initiate SystemService');
      _cache = new SystemService._internal(prefs: prefs);
    } else {
      print('SystemService initiated already');
    }
    return _cache;
  }

  /// SharedPreferences instance
  final SharedPreferences _prefs;

  /// get [dynamic] from [SharedPreferences]
  dynamic get(String key) => _prefs.get(key);

  /// get [String] from [SharedPreferences]
  String getString(String key) => _prefs.getString(key);

  /// get [List<String>] from [SharedPreferences]
  List<String> getStringList(String key) => _prefs.getStringList(key);

  /// get [double] from [SharedPreferences]
  double getDouble(String key) => _prefs.getDouble(key);

  /// get [int] from [SharedPreferences]
  int getInt(String key) => _prefs.getInt(key);

  /// get [bool] from [SharedPreferences]
  bool getBool(String key) => _prefs.getBool(key);

  /// get [Set<String] from [SharedPreferences]
  Set<String> getKeys() => _prefs.getKeys();

  /// set [String] value to [SharedPreferences]
  void setString(String key, String value) => _prefs.setString(key, value);

  /// set [double] value to [SharedPreferences]
  void setDouble(String key, double value) => _prefs.setDouble(key, value);

  /// set [int] value to [SharedPreferences]
  void setInt(String key, int value) => _prefs.setInt(key, value);

  /// set [bool] value to [SharedPreferences]
  void setBool(String key, bool value) => _prefs.setBool(key, value);

  /// set [List<String>] value to [SharedPreferences]
  void setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  /// controller of stream
  final StreamController<dynamic> _streamController;

  /// get a [Stream]
  Stream get _stream => _streamController.stream;

  /// fire a event
  /// value = [String eventName, dynamic data]
  void send(value) => _streamController.add(value);

  /// add listener and return [StreamSubscription]
  StreamSubscription<T> listen<T>(void onData(T event)) {
    return _stream.listen(onData);
  }

  /// device's platform
  bool get isAndroid => Platform.isAndroid;

  bool get isIOS => Platform.isIOS;

  bool get isFuchsia => Platform.isFuchsia;

  /// Check a [permission] and return a [Future] with the result
  Future<bool> checkPermission(permission) =>
      SimplePermissions.checkPermission(permission);

  /// Request a [permission] and return a [Future] with the result
  Future<bool> requestPermission(permission) =>
      SimplePermissions.requestPermission(permission);

  /// Open app settings on Android and iOs
  Future<bool> openSettings() => SimplePermissions.openSettings();

  /// Get iOs permission status
  Future<PermissionStatus> getPermissionStatus(Permission permission) =>
      SimplePermissions.getPermissionStatus(permission);

  FileService _fileService;

  FileService get fileService {
    if (null == _fileService) {
      _fileService = new FileService();
    }
    return _fileService;
  }

  BookService _bookService;

  BookService get bookService {
    if (null == _bookService) {
      _bookService = new BookService();
    }
    return _bookService;
  }
}
