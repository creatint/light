import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show required;
import '../models/book.dart';

class BookItem extends StatelessWidget {
  BookItem(
      {@required this.book,
      @required this.showReadProcess,
      @required this.onTap,
      @required this.onLongPress,
      @required this.inSelect});

  final Book book;
  final bool inSelect;
  final ValueChanged<Book> onTap;
  final ValueChanged<Book> onLongPress;
  final bool showReadProcess;

  Color get titleColor =>
      allPalettes[new Random(book.title.hashCode).nextInt(1000) %
              (allPalettes.length - 1)]
          .primary[50];

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () => onTap(book),
      onLongPress: () => onLongPress(book),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Expanded(
            child: new Container(
              color: allPalettes[book.title.hashCode % (allPalettes.length - 1)]
                  .primary[200],
              child: new Stack(
                children: <Widget>[
                  new SizedBox.expand(
                    child: new Container(
                      padding: const EdgeInsets.all(10.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Text(book.typeString ?? 'Book',
                              style: new TextStyle(
                                  fontSize: 20.0, color: Colors.black45)),
                          new Text(
                            book.title ?? 'Name',
                            style: new TextStyle(
                                fontSize: 10.0, color: Colors.brown),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          new Container(
            height: 37.0,
            child: new Text(
              book.title ?? 'Name',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}

class Palette {
  Palette({this.name, this.primary, this.accent, this.threshold: 900});

  final String name;
  final MaterialColor primary;
  final MaterialAccentColor accent;
  final int
      threshold; // titles for indices > threshold are white, otherwise black

  bool get isValid => name != null && primary != null && threshold != null;
}

final List<Palette> allPalettes = <Palette>[
  new Palette(
      name: 'RED',
      primary: Colors.red,
      accent: Colors.redAccent,
      threshold: 300),
  new Palette(
      name: 'PINK',
      primary: Colors.pink,
      accent: Colors.pinkAccent,
      threshold: 200),
  new Palette(
      name: 'PURPLE',
      primary: Colors.purple,
      accent: Colors.purpleAccent,
      threshold: 200),
  new Palette(
      name: 'DEEP PURPLE',
      primary: Colors.deepPurple,
      accent: Colors.deepPurpleAccent,
      threshold: 200),
  new Palette(
      name: 'INDIGO',
      primary: Colors.indigo,
      accent: Colors.indigoAccent,
      threshold: 200),
  new Palette(
      name: 'BLUE',
      primary: Colors.blue,
      accent: Colors.blueAccent,
      threshold: 400),
  new Palette(
      name: 'LIGHT BLUE',
      primary: Colors.lightBlue,
      accent: Colors.lightBlueAccent,
      threshold: 500),
  new Palette(
      name: 'CYAN',
      primary: Colors.cyan,
      accent: Colors.cyanAccent,
      threshold: 600),
  new Palette(
      name: 'TEAL',
      primary: Colors.teal,
      accent: Colors.tealAccent,
      threshold: 400),
  new Palette(
      name: 'GREEN',
      primary: Colors.green,
      accent: Colors.greenAccent,
      threshold: 500),
  new Palette(
      name: 'LIGHT GREEN',
      primary: Colors.lightGreen,
      accent: Colors.lightGreenAccent,
      threshold: 600),
  new Palette(
      name: 'LIME',
      primary: Colors.lime,
      accent: Colors.limeAccent,
      threshold: 800),
  new Palette(
      name: 'YELLOW', primary: Colors.yellow, accent: Colors.yellowAccent),
  new Palette(name: 'AMBER', primary: Colors.amber, accent: Colors.amberAccent),
  new Palette(
      name: 'ORANGE',
      primary: Colors.orange,
      accent: Colors.orangeAccent,
      threshold: 700),
  new Palette(
      name: 'DEEP ORANGE',
      primary: Colors.deepOrange,
      accent: Colors.deepOrangeAccent,
      threshold: 400),
  new Palette(name: 'BROWN', primary: Colors.brown, threshold: 200),
  new Palette(name: 'GREY', primary: Colors.grey, threshold: 500),
  new Palette(name: 'BLUE GREY', primary: Colors.blueGrey, threshold: 500),
];
