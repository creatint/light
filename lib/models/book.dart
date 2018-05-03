import 'dart:io';
import 'package:flutter/foundation.dart' show required;
import '../utils/utils.dart';

class Book {
  Book(
      {@required this.title,
      @required this.coverUri,
      @required this.uri,
      @required this.type,
      @required this.updateAt,
      @required this.createAt});

  Book.fromFile(FileSystemEntity file)
      : assert(file != null),
        assert(!FileSystemEntity.isDirectorySync(file.path)),
        title = getFileBaseName(file),
        coverUri = null,
        uri = file.path,
        type = getFileType(file),
        updateAt = new DateTime.now().toIso8601String(),
        createAt = new DateTime.now().toIso8601String();

  Book.fromJson(Map<String, dynamic> value)
      : assert(value != null),
        assert(value.isNotEmpty),
        title = value['title'],
        coverUri = value['coverUri'],
        uri = value['uri'],
        type = getColumn('type', value),
        updateAt = value['updateAt'],
        createAt = value['createAt'];

  final String title;
  final String coverUri;
  final String uri;
  final FileType type;
  final String updateAt;
  final String createAt;

  static getColumn(String key, [Map<String, dynamic> json]) {
    switch (key) {
      case 'type':
        return FileType.values.firstWhere((v) => v.toString() == json[key]);
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'coverUri': coverUri,
      'uri': uri,
      'type': type.toString(),
      'updateAt': updateAt,
      'createAt': createAt
    };
  }

  String get typeString {
    return new RegExp(r'\.([a-z]+)$', caseSensitive: false)
        .firstMatch(type.toString())
        ?.group(1);
  }

  operator ==(dynamic value) {
    if (null == value || value is! Book) return false;
    return value.uri == this.uri;
  }
}
