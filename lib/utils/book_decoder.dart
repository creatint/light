import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show required, compute;
import 'package:epub/epub.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import '../models/book.dart';
import '../models/chapter.dart';
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
//        Map<String, dynamic> data =
//        await compute<String, Future<Map<String, dynamic>>>(
//            decodeEpub, book.uri);
          data = await _decodeEpub(book.uri);
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

  String getSection(int offset, int length) {
    if (null == content || (offset + length) > content.length) {
      return null;
    }
    return content.substring(offset, length);
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

Future<Map<String, dynamic>> _decodeEpub(String uri) async {
  try {
    print('decode epub...');
    File targetFile = new File(uri);
    List<int> bytes = await targetFile.readAsBytes();
    String content = '';
    List<Chapter> chapters = <Chapter>[];

    // Opens a book and reads all of its content into the memory
    EpubBook epubBook = await EpubReader.readBook(bytes);

//    content = epubBook.Content.toString();
    epubBook.Chapters?.forEach((EpubChapter chapter) {
      if (null != chapter) {
        dom.Document doc = parse(chapter.HtmlContent);
        String text = doc.body.text;
        chapters.add(new Chapter(
            title: chapter.Title,
            offset: content?.length,
            length: text?.length));
        content += text;
      }

//      dom.Document document = parse(html);
//      dom.Element body = document.body;
//    return hm.convert(body.outerHtml);
//    return body.outerHtml;
//      return body.text;
    });
    return {'content': content, 'chapters': chapters};
  } catch (e) {
    print('decode epub failed, e: $e');
    throw e;
  }
}
