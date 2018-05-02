import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show required;

class Paging {
  Paging(
      {@required Size size,
      @required TextStyle textStyle,
      int maxLines,
      TextAlign textAlign: TextAlign.left,
      TextDirection textDirection: TextDirection.ltr})
      : assert(null != size),
        assert(null != textStyle),
        assert(null != textAlign),
        assert(null != textDirection),
        _maxLines = maxLines,
        _textPainter =
            new TextPainter(textAlign: textAlign, textDirection: textDirection);

  /// view size
  Size _size;

  int _maxLines;

  TextStyle _textStyle;

  TextAlign _textAlign;

  TextDirection _textDirection;

  TextPainter _textPainter;

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

  /// if overflow, return true
  bool layout(String text) {
    _textPainter
      ..text = new TextSpan(text: text, style: _textStyle)
      ..layout(maxWidth: _size.width);
    return _textPainter.didExceedMaxLines ||
        _textPainter.size.height > _size.height;
  }

  /// max length of string displayed on viewport.
  int get maxLength {
    return _textPainter
        .getPositionForOffset(_size.bottomRight(Offset.zero))
        .offset;
  }
}
