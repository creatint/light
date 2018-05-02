import 'dart:io';

enum FileType { TEXT, EPUB, PDF, OTHER, NOT_FOUND, DIRECTORY }


RegExp _regBasename = new RegExp(r'[^/\\]+$');
RegExp _regFileType = new RegExp(r'([^.\\/]+)$');
RegExp _regTXT = new RegExp(r'txt');
RegExp _regPDF = new RegExp(r'pdf');
RegExp _regEPUB = new RegExp(r'epub');
RegExp _regName = new RegExp(r'(.+)[^.]+$');

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
    else
      type = FileType.OTHER;
    return type;
  }
  return FileType.NOT_FOUND;
}
