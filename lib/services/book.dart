import 'dart:io';
import 'dart:async';
import 'dart:convert';
import '../services/system.dart';
import '../utils/utils.dart';
import '../utils/constants.dart';
import '../models/book.dart';

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
    String booksJson = service.getString(books_key);
    if (null == booksJson || booksJson.isEmpty) {
      return null;
    }
    _books = <String, Book>{};
    Map<String, dynamic> booksMap = json.decode(booksJson);
    booksMap.forEach((String key, dynamic value){
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
      count ++;
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
    list.forEach((Book v){
      books.removeWhere((_, Book book)=> book.uri == v.uri);
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
}
