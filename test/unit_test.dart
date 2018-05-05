import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:light/utils/constants.dart';
import 'package:light/models/style.dart';
import 'package:light/services/system.dart';
import 'styles.dart';

void main() {
  group('Style', () {
    const MethodChannel channel = const MethodChannel(
      'plugins.flutter.io/shared_preferences',
    );

    const Map<String, dynamic> kTestValues = const <String, dynamic>{
      'flutter.$test_key': null,
    };

    final List<MethodCall> log = <MethodCall>[];
    SharedPreferences preferences;
    SystemService service;
    List<Style> styles;
    List<Map<String, dynamic>> jsons;

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'getAll') {
          return kTestValues;
        }
        return null;
      });
      preferences = await SharedPreferences.getInstance();
      service = new SystemService(prefs: preferences);

      styles = list.map((v) => new Style.fromJson(v)).toList();
      jsons = styles.map((v) => v.toJson()).toList();
    });

    test('read style json', () {
      expect(jsons.length, equals(list.length));
    });

//    test('to json', () async {
//      expect(preferences.get(test_key), null);
//    });

  });
}