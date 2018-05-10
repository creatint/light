import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import '../services/system.dart';
import '../utils/utils.dart';
import '../utils/constants.dart';
import '../models/book.dart';
import '../models/pagination.dart';

class BookService {
  static BookService _cache;

  factory BookService() {
    if (null == _cache) {
      _cache = new BookService._internal();
    }
    return _cache;
  }

  BookService._internal();

  SystemService service = new SystemService();

  static Map<String, Book> _books;

  /// get books from prefs
  Map<String, Book> getBooks() {
    if (null != _books) {
      return _books;
    }
    String booksJson = service.getString(books_key);
    if (null == booksJson || booksJson.isEmpty) {
      return null;
    }
    _books = <String, Book>{};
    Map<String, dynamic> booksMap = json.decode(booksJson);
    booksMap.forEach((String key, dynamic value) {
      _books[key] = new Book.fromJson(value);
    });
    return _books;
  }

  /// refresh and store books cache
  int addBooks(List<Book> books) {
    if (null == books || books.isEmpty) {
      return 0;
    }
    Map<String, Book> cacheBooks = getBooks();
    if (null != cacheBooks && cacheBooks.isNotEmpty) {
//      books.removeWhere((Book v) => cacheBooks.containsKey(v.uri));
    } else {
      cacheBooks = <String, Book>{};
    }
    int count = 0;
    books.forEach((Book v) {
      print(v.toJson());
      count++;
      cacheBooks[v.uri] = v;
    });
    _books = cacheBooks;
    Map<String, dynamic> jsons = <String, dynamic>{};
    _books.forEach((String key, Book book) {
      jsons[key] = book.toJson();
    });
    service.setString(books_key, json.encode(jsons));
    return count;
  }

  int removeBooks(List<Book> list) {
    if (null == list || list.isEmpty) return 0;
    Map<String, Book> books = getBooks();
    int start = books.length;
    list.forEach((Book v) {
      books.removeWhere((_, Book book) => book == v);
    });
    _books = books;
    Map<String, dynamic> jsons = <String, dynamic>{};
    _books.forEach((String key, Book book) {
      jsons[key] = book.toJson();
    });
    service.setString(books_key, json.encode(jsons));
    return start - books.length;
  }

  void removeBook(Book book) {
    Map<String, Book> books = getBooks();
    if (books.containsKey(book.uri)) {
      books.remove(book.uri);
    }
    _books = books;
    Map<String, dynamic> jsons = <String, dynamic>{};
    _books.forEach((String key, Book book) {
      jsons[key] = book.toJson();
    });
    service.setString(books_key, json.encode(jsons));
  }

  FutureOr<int> importLocalBooks(List<FileSystemEntity> list) async {
    if (null == list || list.isEmpty) {
      return 0;
    }
    List<Book> books = <Book>[];
    list.forEach((FileSystemEntity file) {
      if (!fileIsBook(file)) return 0;
      books.add(new Book.fromFile(file));
    });
    return addBooks(books);
  }

  Map<String, dynamic> _settings = {
    'fontSize': 20.0,
    'height': 1.2,
    'textAlign': TextAlign.left,
    'textDirection': TextDirection.ltr
  };

  Map<String, dynamic> getSettings() {
    return _settings;
  }

  /// the offset of book being read
  Map<String, int> _offsets;

  Map<String, int> get offsets {
    if (null == _offsets) {
      String raw = service.getString(books_progress);

      if (null == raw) {
        _offsets = <String, int>{};
      } else {
        _offsets = json.decode(raw).cast<String, int>();
      }
    }
    return _offsets;
  }

  /// set offset for book
  void setOffset(Book book, int offset) {
    assert(offset >= 0);
    assert(null != book);
    _offsets[book.uri] = offset;
    service.setString(books_progress, json.encode(_offsets).toString());
  }

  /// get the progress of reading
  int getOffset(Book book) {
    assert(null != book);
    if (!offsets.containsKey(book.uri)) {
      setOffset(book, 0);
    }
    return _offsets[book.uri];
  }


  /// Get paging data of the book.
  Map<String, List<List<int>>> getPagingData(Book book) {
    assert(null != book);
    if (null == book) return null;
    String raw = service.getString(book.uri + paging_data_suffix);
    if (null == raw || raw.isEmpty) {
      return null;
    }
    var data = json.decode(raw).cast<Map<String, List<List<int>>>>();
    return data[book.uri];
  }

  void setPagingData(Book book, var data) {

  }
}
