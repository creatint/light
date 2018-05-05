import 'dart:io';
import 'dart:convert';
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
    List<Style> newStyles;
    List<dynamic> newJsons;

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

      /// put json to file
      File file = new File('test/styles.json');
      file.writeAsStringSync(json.encode(jsons));

      /// read json from file
      newJsons = json.decode(file.readAsStringSync());

      /// get styles from json
      styles = jsons.map((v) => new Style.fromJson(v)).toList();

      /// get new styles from new json
      newStyles = newJsons.map((v) => new Style.fromJson(v)).toList();
    });

    test('put json to file', () {
      expect(newJsons.toString(), equals(jsons.toString()));
    });

    test('get styles from json', (){
      expect(newStyles, equals(styles));
    });
  });
}