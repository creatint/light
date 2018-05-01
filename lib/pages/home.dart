import 'package:flutter/material.dart';
import '../widgets/drawer.dart';
import 'shelf.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: scaffoldKey,
        drawer: new MyDrawer(),
        body: new Shelf(
          scaffoldKey: scaffoldKey,
        ));
  }
}
