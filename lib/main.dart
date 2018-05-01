import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/app.dart';
import 'services/system.dart';

void main() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  new SystemService(prefs: prefs);
  runApp(new App());
}
