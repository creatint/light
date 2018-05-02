import 'dart:io';

enum FileType {
  TEXT,
  EPUB,
  PDF,
  IMAGE,
  VIDEO,
  AUDIO,
  OTHER,
  NOT_FOUND,
  DIRECTORY
}

RegExp _regBasename = new RegExp(r'[^/\\]+$');
RegExp _regFileType = new RegExp(r'([^.\\/]+)$');
RegExp _regTXT = new RegExp(r'txt');
RegExp _regPDF = new RegExp(r'pdf');
RegExp _regEPUB = new RegExp(r'epub');
RegExp _regIMAGE = new RegExp(r'jpe?g|png|gif|bmp');
RegExp _regVIDEO = new RegExp(r'mp4|rmvb|avi|mov|wmv|rm|flash|mid|3gp|'
    r'mpeg|m4v|mkv|flv|vob|asf|mpeg4');
RegExp _regAUDIO = new RegExp(r'mp3|ogg|cd|mp3pro|real|wma'
    r'|ape|midi|vqf');
//RegExp _regName = new RegExp(r'(.+)[^.]+$');

String getFileName(dynamic file) {
  if (file is String) {
    return _regBasename.firstMatch(file)?.group(0);
  } else if (file is Directory || file is FileSystemEntity) {
    return file.path.substring(file.parent.path.length + 1, file.path.length);
  } else {
    return '';
  }
}

String getFileSuffix(dynamic file) {
  String name = getFileName(file);
  return _regFileType.firstMatch(name)?.group(1);
}

FileType getFileType(FileSystemEntity file) {
  if (file.existsSync()) {
    if (FileSystemEntity.isDirectorySync(file.path)) {
      return FileType.DIRECTORY;
    }
    FileType type;
    String suffix = getFileSuffix(file);
    if (null == suffix || suffix.isEmpty) {
      type = FileType.OTHER;
    } else if (_regTXT.hasMatch(suffix))
      type = FileType.TEXT;
    else if (_regPDF.hasMatch(suffix))
      type = FileType.PDF;
    else if (_regEPUB.hasMatch(suffix))
      type = FileType.EPUB;
    else if (_regIMAGE.hasMatch(suffix))
      type = FileType.IMAGE;
    else if (_regVIDEO.hasMatch(suffix))
      type = FileType.VIDEO;
    else if (_regAUDIO.hasMatch(suffix))
      type = FileType.AUDIO;
    else
      type = FileType.OTHER;
    return type;
  }
  return FileType.NOT_FOUND;
}

bool typeIsBook (FileType type) {
  switch (type) {
    case FileType.TEXT:
    case FileType.EPUB:
//    case FileType.PDF:
      return true;
    default:
      return false;
  }
}

bool fileIsBook(FileSystemEntity file) {
  if (FileSystemEntity.isDirectorySync(file.path)) return false;
  return typeIsBook(getFileType(file));
}


typedef E ValuePipe<T, E>(T value);
