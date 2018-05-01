import 'package:flutter/material.dart';

class Shelf extends StatefulWidget {
  Shelf({@override this.scaffoldKey});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _ShelfState createState() => new _ShelfState();
}

class _ShelfState extends State<Shelf> {
  /// open drawer
  void handleDrawer() {
    widget.scaffoldKey.currentState.openDrawer();
  }

  /// open search page
  void handleSearch() {
    Navigator.pushNamed(context, 'search');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
            icon: new Icon(
              Icons.menu,
              color: Theme.of(context).accentIconTheme.color,
            ),
            onPressed: handleDrawer),
        title: new Text('Light'),
        actions: <Widget>[
          new IconButton(
              icon: const Icon(Icons.search), onPressed: handleSearch),
        ],
      ),
      body: new Container(
        child: new Text('hello world'),
      ),
    );
  }
}
