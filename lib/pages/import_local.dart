import 'package:flutter/material.dart';

class ImportLocal extends StatefulWidget {
  @override
  _ImportLocalState createState() => _ImportLocalState();
}

class _ImportLocalState extends State<ImportLocal> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Text('import local books'),
      ),
    );
  }
}