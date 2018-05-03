import 'package:flutter/foundation.dart' show required;

class Chapter {
  Chapter({@required this.title, @required this.offset, @required this.length});

  final String title;
  final int offset;
  final int length;
}
