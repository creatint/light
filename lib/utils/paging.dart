import 'package:flutter/material.dart';
import '../models/style.dart';
//import 'package:light/services/book.dart';

class Paging {
  Paging({
    Size size,
    int maxLines,
  })  : _size = size,
        _maxLines = maxLines,
        _textPainter = new TextPainter() {
    _textStyle = Style.textStyle;
    _textAlign = Style.textAlign;
    _textDirection = Style.textDirection;
    _textPainter.textAlign = _textAlign;
    _textPainter.textDirection = _textDirection;
  }

//  BookService bookService = new BookService();

  /// view size
  Size _size;

  int _maxLines;

  TextStyle _textStyle;

  TextAlign _textAlign;

  TextDirection _textDirection;

  TextPainter _textPainter;

  set size(Size size) {
    _size = size;
  }

  set maxLines(int maxLines) {
    _maxLines = maxLines;
    _textPainter.maxLines = _maxLines;
  }

  set textStyle(TextStyle textStyle) {
    _textStyle = textStyle;
  }

  set textAlign(TextAlign textAlign) {
    _textAlign = textAlign;
    _textPainter.textAlign = _textAlign;
  }

  set textDirection(TextDirection textDirection) {
    _textDirection = textDirection;
    _textPainter.textDirection = _textDirection;
  }

  /// if overflow, return true.
  /// when layout runs, it needs size, textStyle, and text.
  bool layout(String text, {bool onSize: false}) {
    assert(_textStyle != null);
    assert(_textAlign != null);
    assert(_textDirection != null);
    assert(_textPainter != null);
    assert(_size != null);
    assert(text != null);
    _textPainter
      ..text = new TextSpan(text: text, style: _textStyle)
      ..layout(maxWidth: _size.width);
    _textPainter.size;
    _textPainter.didExceedMaxLines;
    if (false ==onSize) {
      return _textPainter.didExceedMaxLines ||
          _textPainter.size.height > _size.height;
    } else {
      return _textPainter.size.height > _size.height;
    }
  }

  /// max length of string displayed on viewport.
  int get maxLength {
    return _textPainter
        .getPositionForOffset(_size.bottomRight(Offset.zero))
        .offset;
  }

}
