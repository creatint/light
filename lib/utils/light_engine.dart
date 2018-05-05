import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show required;
import 'paging.dart';
import 'book_decoder.dart';
import '../services/system.dart';
import '../services/book.dart';
import '../models/book.dart';
import '../models/pagination.dart';
import '../models/style.dart';

class LightEngine {
  static Map<Book, LightEngine> _cache;

  /// used to reset state
  final ValueChanged<VoidCallback> _stateSetter;

  factory LightEngine(
      {@required Book book, @required ValueChanged<VoidCallback> stateSetter}) {
//    if (null == _cache) {
      _cache = <Book, LightEngine>{};
//    }
    if (!_cache.containsKey(book)) {
      _cache[book] =
          new LightEngine._internal(book: book, stateSetter: stateSetter);
    }
    return _cache[book];
  }

  final Book _book;

  final SystemService _service = new SystemService();

  StreamSubscription _streamSubscription;

  Style _style;

  LightEngine._internal({Book book, ValueChanged<VoidCallback> stateSetter})
      : assert(null != book),
        assert(null != stateSetter),
        _book = book,
        _stateSetter = stateSetter {
    _streamSubscription = _service.listen(_listener);
  }

  void _listener(var event) {
    if (null != event && event is List && event.isNotEmpty) {
      switch (event[0]) {
        case '':
          break;
      }
    }
  }

  PageController _pageController;

  BookDecoder _decoder;

  Future<PageController> get controller async {
    if (null == _pageController) {
      if (null == _decoder) {
        _decoder = await BookDecoder.decode(_book);
      }
      if (null == Style.values) {
        await Style.init();
      }
      _pageController = new PageController();
    }
    return _pageController;
  }

  List<Style> get styles => Style.values;

  Style get style {
    return Style.values[Style.currentId];
  }

  int childCount = 1;


  String get title {
    return 'title...';
  }

  String getContent(int index) {
    return _decoder.getSection(0, 400);
  }

  void _initState() {}

  void _setState() {
    _stateSetter(() {});
  }

  /// calculate the hashCode to just whether to repaint
  void _needRepaint() {}


  void close() {
    _streamSubscription?.cancel();
    _cache[_book] = null;
  }
}
