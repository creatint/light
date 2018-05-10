import 'dart:async';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlay;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show required;
import '../../services/system.dart';
import '../../models/book.dart';
import '../../utils/light_engine.dart';
import '../../widgets/text_indicator.dart';
import '../../models/style.dart';

class Reader extends StatefulWidget {
  Reader({@required this.book});

  /// the book be read
  final Book book;

  _ReaderState createState() => new _ReaderState();
}

class _ReaderState extends State<Reader> {
  SystemService service = new SystemService();
  LightEngine lightEngine;

  /// the ratio to slice the screen
  Map<String, List<int>> tapRatio = <String, List<int>>{
    'x': [1, 1, 1],
    'y': [1, 1, 1]
  };

  /// the area tapped
  Map<String, double> tapGrid = <String, double>{};

  /// the size of screen
  Size mediaSize;

  bool isShowMenu = false;

  ///
  PageController pageController;

  Future<PageController> pageControllerFuture;

  SliverChildBuilderDelegate childBuilderDelegate;

  /// to change the page
  void handlePageChanged(bool value) {}

  /// tu show menu
  Future<Null> handleShowMenu() async {
    return;
  }

  /// detect tap event
  void handleTapUp(TapUpDetails tapUpDetails) {
    double x = tapUpDetails.globalPosition.dx;
    double y = tapUpDetails.globalPosition.dy;
    if (tapGrid.isEmpty) {
      double x1 = mediaSize.width *
          (tapRatio['x'][0] /
              (tapRatio['x'][0] + tapRatio['x'][1] + tapRatio['x'][2]));
      double x2 = mediaSize.width *
          ((tapRatio['x'][0] + tapRatio['x'][1]) /
              (tapRatio['x'][0] + tapRatio['x'][1] + tapRatio['x'][2]));
      double y1 = mediaSize.height *
          (tapRatio['y'][0] /
              (tapRatio['y'][0] + tapRatio['y'][1] + tapRatio['y'][2]));
      double y2 = mediaSize.height *
          ((tapRatio['y'][0] + tapRatio['y'][1]) /
              (tapRatio['y'][0] + tapRatio['y'][1] + tapRatio['y'][2]));
      tapGrid['x1'] = x1;
      tapGrid['x2'] = x2;
      tapGrid['y1'] = y1;
      tapGrid['y2'] = y2;
    }
    if (x <= tapGrid['x1']) {
      // previous page
      handlePageChanged(false);
    } else if (x >= tapGrid['x2']) {
      // next page
      handlePageChanged(true);
    } else {
      if (y <= tapGrid['y1']) {
        // previous page
        handlePageChanged(false);
      } else if (y >= tapGrid['y2']) {
        // next page
        handlePageChanged(true);
      } else {
        // open the menu
        isShowMenu = true;
        handleShowMenu().then((value) {
          if (true == value) {}
        });
      }
    }
  }

  ThemeData get theme {
    return Theme.of(context);
  }

  TextStyle get waitingTextStyle {
    return theme.textTheme.body2.copyWith(color: Colors.white70);
  }

  Widget pageBuilder(BuildContext contxt, int index) {
    return new Container(
      decoration: new BoxDecoration(
          color: lightEngine.style.backgroundColor,
          image: lightEngine.style.image),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            height: 30.0,
            child: new Row(
              children: <Widget>[
                new Text(lightEngine.title),
              ],
            ),
          ),
          new Expanded(
            child: new Container(
              color: Colors.yellow,
              child: new Text(
                lightEngine.getContent(index),
                style: Style.textStyle,
                overflow: TextOverflow.clip,
                maxLines: lightEngine.maxLines,
                textScaleFactor: 1.0,
              ),
            ),
          ),
          new SizedBox(
            height: 30.0,
            child: new Row(
              children: <Widget>[
                new Text('底部信息'),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    lightEngine = new LightEngine(book: widget.book, stateSetter: setState);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
          lightEngine.pageSize =
              new Size(constraint.maxWidth - 40.0, constraint.maxHeight - 60.0);
          if (null == pageControllerFuture) {
            pageControllerFuture = lightEngine.controller;
          }
          return new Container(
            color: Colors.black45,
            child: new FutureBuilder(
                future: pageControllerFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<PageController> snapshot) {
                  if (ConnectionState.waiting == snapshot.connectionState) {
                    return new Center(
                      child: new TextIndicator(),
                    );
                  } else if (ConnectionState.done == snapshot.connectionState &&
                      !snapshot.hasError &&
                      snapshot.hasData &&
                      snapshot.data is PageController) {
                    pageController = snapshot.data;
                    return PageView.custom(
                        childrenDelegate: new SliverChildBuilderDelegate(
                            pageBuilder,
                            childCount: lightEngine.childCount,
                            addRepaintBoundaries: false,
                            addAutomaticKeepAlives: false));
                  } else {
                    return new Container(
                      padding: const EdgeInsets.all(20.0),
                      child: new Center(
                        child: new Text(
                          '解析失败：${snapshot.error}',
                          style: waitingTextStyle,
                        ),
                      ),
                    );
                  }
                }),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    lightEngine.close();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }
}
