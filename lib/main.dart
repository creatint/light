import 'package:flutter/material.dart';
import 'pages/app.dart';
import 'utils/initial.dart';

void main() async {
  /// initialize the app
  await initial();

  /// run the app
  runApp(new App());
}
