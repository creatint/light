import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show required, compute;
import 'package:epub/epub.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import '../models/book.dart';
import '../models/chapter.dart';
import '../models/section.dart';
import '../utils/utils.dart';

class BookDecoder {
  BookDecoder({@required this.content, @required this.chapters})
      : assert(null != content),
        assert(null != chapters);

  static Book _book;

  final String content;
  final List<Chapter> chapters;

  static Future<BookDecoder> decode(Book book) async {
    print('decode ${book.title}...');
    Map<String, dynamic> data;

    _book = book;
    try {
      switch (book.type) {
        case FileType.TEXT:
          data = await compute(_decodeText, book.uri);
          break;
        case FileType.EPUB:
          // todo: decode in second isolate
          data = await compute<String, Map<String, dynamic>>(
              _decodeEpub, book.uri);
          print(data['chapters']);
          if (null != data['chapters']) {
            data['chapters'] = jsonDecode(data['chapters'])
                .map<Chapter>((value) => new Chapter.fromJson(value))
                .toList();
          }
          break;
        default:
      }
      print('decode complete');
    } catch (e) {
      print('decode err: $e');
      throw e;
    }
    return new BookDecoder(
        content: data['content'], chapters: data['chapters']);
  }

  int get maxLength => content?.length;

  dynamic getSection(int offset, int length, {bool raw: false}) {
    print('get section offset=$offset length=$length');
    print('content.length = ${content.length}');
    String text;
    if (!(offset >= 0) || !(length > 0)) {
      return null;
    }
    if (offset >= maxLength) {
      return null;
    }
    if (offset + length >= maxLength) {
      text = content.substring(offset, maxLength);
    } else {
      text = content.substring(offset, offset + length);
    }
    if (true == raw) {
      return text;
    } else {
      return new Section(title: 'title...', content: text);
    }
  }

  /// free the memory
  void close() {}
}

Map<String, dynamic> _decodeText(String uri) {
  try {
    File file = new File(uri);
    RandomAccessFile randomAccessFile = file.openSync(mode: FileMode.READ);
    String charset = charsetDetector(randomAccessFile);
    String content = '';
    List<Chapter> chapters = <Chapter>[];
    switch (charset) {
      case 'gbk':
        throw new Exception('gbk格式暂不支持');
        break;
      case 'utf8':
        content = utf8.decode(file.readAsBytesSync(), allowMalformed: true);
        break;
      case 'latin1':
        content = latin1.decode(file.readAsBytesSync());
        break;
      default:
        throw new Exception('不支持的文件格式');
    }
    randomAccessFile.close();
    return {'content': content, 'chapters': chapters};
  } catch (e) {
    print('decode text err: $e');
    throw e;
  }
}

Map<String, dynamic> _decodeEpub(String uri) {
  try {
    print('decode epub...');
    File targetFile = new File(uri);
    List<int> bytes = targetFile.readAsBytesSync();
    String content = '';
    List<Map> chapters = <Map>[];

    // Opens a book and reads all of its content into the memory
    EpubBook epubBook = EpubReader.readBookSync(bytes);

//    content = epubBook.Content.toString();
    epubBook.Chapters?.forEach((EpubChapter chapter) {
      if (null != chapter) {
        dom.Document doc = parse(chapter.HtmlContent);
        String text = doc.body.text;
        chapters.add({
          'title': chapter.Title,
          'offset': content?.length,
          'length': text?.length
        });
        content += text;
      }

//      dom.Document document = parse(html);
//      dom.Element body = document.body;
//    return hm.convert(body.outerHtml);
//    return body.outerHtml;
//      return body.text;
    });
    return {'content': content, 'chapters': jsonEncode(chapters).toString()};
  } catch (e) {
    print('decode epub failed, e: $e');
    throw e;
  }
}
