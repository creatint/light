import 'package:flutter/material.dart';
import 'home.dart';
import 'import_local.dart';
import 'search.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => new _AppState();
}

class _AppState extends State<App> {

  /// initial app
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Home(),
      routes: <String, WidgetBuilder> {
        'importLocal': (BuildContext context) => new ImportLocal(),
        'search': (BuildContext context) => new Search(),
      },
    );
  }
}

