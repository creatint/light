import 'package:flutter/material.dart';
import 'home.dart';
import 'import_local.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => new _AppState();
}

class _AppState extends State<App> {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Home(),
      routes: <String, WidgetBuilder> {
        'importLocal': (BuildContext context) => new ImportLocal()
      },
    );
  }
}

