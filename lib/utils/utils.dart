import 'dart:io';

RegExp _regBasename = new RegExp(r'[^/\\]+$');

String getFileName(dynamic file) {
  if (file is String) {
    return _regBasename.firstMatch(file)?.group(0);
  } else if (file is Directory || file is FileSystemEntity) {
    return file.path.substring(file.parent.path.length + 1, file.path.length);
  } else {
    return '';
  }
}
