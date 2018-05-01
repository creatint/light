import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/app.dart';
import 'services/system.dart';
import 'utils/initial.dart';

void main() async {
  /// get instance of SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  /// get instance of SystemService
  new SystemService(prefs: prefs);

  /// initialize the app
  await initial();

  /// run the app
  runApp(new App());
}
