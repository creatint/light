import 'package:flutter/foundation.dart' show required;
import 'package:flutter/material.dart';

//import '../services/system.dart';
import '../services/book.dart';
import '../models/book.dart';
import '../models/style.dart';
import '../models/section.dart';
import '../utils/book_decoder.dart';
import '../utils/constants.dart';
import '../utils/paging.dart';

/// Get paging data by pagingHashCode.
/// If dose not exist, calculates paging data with [Book] and [BookDecoder].
///
/// [Style] must have been initialized already,
/// which will be used to calculate paging data.
/// If there's not data for current pagingHashCode, use temporary data,
/// At the same, start calculating paging data.
/// When finish calculating, replace the temporary with the correct data.
class Pagination {
  Pagination(
      {@required Book book,
      @required BookDecoder bookDecoder,
      @required Size size,
      int estimateMaxLines: 30})
      : assert(null != book),
        assert(null != bookDecoder),
        assert(null != Style.values),
        assert(null != size),
        _book = book,
        _bookDecoder = bookDecoder,
        _size = size,
        _estimateMaxLines = estimateMaxLines {
    paging = new Paging(size: size, maxLines: estimateMaxLines);
  }

  final Book _book;
  final BookDecoder _bookDecoder;

//  final SystemService service = new SystemService();
  Paging paging;

  Size _size;
  int _maxLines;

  bool isTemporary;

  Map<int, List<int>> _tmpPagingData;

  Map<String, List<int>> _pagingData;

  Map<String, Map<String, List<int>>> _data;

  String _pagingHashCode;

  /// Initialize paging data.
  void init(String pagingHashCode) {
    /// calculate the max lines
    paging.maxLines = maxLines;
    if (null != _pagingHashCode && pagingHashCode == _pagingHashCode) return;
//    _data = service.bookService.getPagingData(_book);
    if (null == _data || !_data.containsKey(pagingHashCode)) {
      /// Use temporary data
      _tmpPagingData = <int, List<int>>{};
      isTemporary = true;

      /// TODO:start to calculate paging data if there is not begin
    } else {
      _pagingData = _data[pagingHashCode];
      isTemporary = false;
    }
    _pagingHashCode = pagingHashCode;
  }

  /// Check paging data whether exists.
  void check(String pagingHashCode) {
    assert(null != pagingHashCode);
    if (null == pagingHashCode) return;
    if (_pagingHashCode == pagingHashCode) {
      return;
    }
    if (null == _data || !_data.containsKey(pagingHashCode)) {
      _tmpPagingData = <int, List<int>>{};
      isTemporary = true;
    } else if (null != _data) {
      _pagingData = _data[pagingHashCode];
      isTemporary = false;
    }
    _pagingHashCode = pagingHashCode;
  }

  List<int> pagingData(int index) {
    if (isTemporary) {
      if (null != _tmpPagingData &&
          _tmpPagingData.isNotEmpty &&
          _tmpPagingData.containsKey(index)) {
        return _tmpPagingData[index];
      }
    } else {
      if (null != _pagingData &&
          _pagingData.isNotEmpty &&
          _pagingData.containsKey(index)) {
        return _pagingData[index];
      }
    }
    return null;
  }

  int _sectionSize = 430;

  operator []=(int index, List<int> data) {
    _tmpPagingData[index] = data;
  }

  Section section;

  operator [](int index) {
    if (null != pagingData(index)) {
      return pagingData(index);
    } else if (null != pagingData(index - 1)) {
      int offset = pagingData(index - 1)[0] + pagingData(index - 1)[1];
      for (int i = 1; i < 20; i++) {
        section = _bookDecoder.getSection(offset, _sectionSize * i);
        if (null == section) {
          break;
        }
        if (paging.layout(section.content)) {
          this[index] = [offset, paging.maxLength];
          break;
        }
      }
    } else {
      for (int i = 1; i < 20; i++) {
        section = _bookDecoder.getSection(0, _sectionSize * i);
        if (paging.layout(section.content)) {
          this[index] = <int>[0, paging.maxLength];
          break;
        }
      }
    }
    return pagingData(index);
  }

  int _estimateMaxLines;

  int get maxLines {
    if (null != _maxLines) return _maxLines;
    paging.maxLines = _estimateMaxLines;
    loop:
    for (int i = 1; i < 20; i++) {
      String text = getSectionDemo(0, _sectionSize * i, raw: true);
      if (!paging.layout(text, onSize: true)) {
        continue;
      } else {
        int start = 0;
        int end = _estimateMaxLines;
        int mid = (start + end) ~/ 2;
        do {
          paging.maxLines = mid;
          if (paging.layout(text, onSize: true)) {
            end = mid;
            mid = (start + end) ~/ 2;
          } else {
            start = mid;
            mid = (start + end) ~/ 2;
          }
          if (start == mid || mid == end) {
            _maxLines = mid;
            break loop;
          }
        } while (true);
        break;
      }
    }
    return _maxLines;
  }

  dynamic getSectionDemo(int offset, int length, {bool raw: false}) {
    String character = '啊啊啊啊啊啊啊啊啊啊';
    String content = '';
    String title = 'get section demo';
    for (int i = 0; i < length; i++) {
      content += character;
      if (content.length > length) {
        content = content.substring(0, length);
        break;
      }
    }
    if (true == raw) {
      return content;
    } else {
      return new Section(title: title, content: content);
    }
  }
}
