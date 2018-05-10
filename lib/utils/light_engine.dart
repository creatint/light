import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show required;
import 'book_decoder.dart';
import '../services/system.dart';
import '../services/book.dart';
import '../models/book.dart';
import '../models/pagination.dart';
import '../models/style.dart';
import '../models/section.dart';
import '../utils/paging.dart';

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

  /// Provide [PageController] to [Reader]
  ///
  /// When there is pageController already, return it.
  /// If not, first decode the book, get all content of the book,
  /// next initialize [Style], used to display, calculate paging data,
  /// then get [Pagination], which may start a second isolate to calculate paging data,
  /// finally instantiate PageController and return it.
  Future<PageController> get controller async {
    print('get controller');
    try {
      if (null == _pageController) {
        if (null == _decoder) {
          _decoder = await BookDecoder.decode(_book);
        }
        print('flag1');
        if (null == Style.values) {
          await Style.init();
        }
        print('flag2');
        if (null == _pagination) {
          _pagination = new Pagination(
              book: _book,
              bookDecoder: _decoder,
              size: _pageSize);
          _pagination.init(pagingHashCode);
        }
        _pageController = new PageController();
      }
      return _pageController;
    } catch (e) {
      print('get controller failed. error: $e');
      throw e;
    }
  }

  List<Style> get styles => Style.values;

  Style get style {
    return Style.values[Style.currentId];
  }

  int childCount = 20;

  String get title {
    return 'title...';
  }

  Pagination _pagination;

  Section section;

  String getContent(int index) {
    try {
      print('get content index=$index');
      var page = _pagination[index];
      section = _decoder.getSection(page[0], page[1]);
      if (null == section) {
        return 'get section error.';
      }
      return section.content;
    } catch (e) {
      print('get content error: $e');
      return e.toString();
    }
  }

  Size _pageSize;

  String _pagingHashCode;

  String _paintHashCode;

  String get pagingHashCode {
    return hashValues(_pageSize, fontSize, lineHeight, textDirection.toString())
        .toString();
  }

  double get fontSize => Style.fontSize;

  double get lineHeight => Style.height;

  TextDirection get textDirection => Style.textDirection;

  /// When set a new Size, check the pagingHashCode,
  /// recalculate pagination if need.
  set pageSize(Size size) {
    assert(null != size);
    print('set page size: $size');
    if (null != _pageSize || size == _pageSize) {
      return;
    }
    _pageSize = size;
    _pagination?.check(pagingHashCode);
  }

  /// get the max lines from Pagination
  int get maxLines => _pagination.maxLines;

  int get estimateMaxLines {
    return _pageSize.height ~/ (fontSize * lineHeight);
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
