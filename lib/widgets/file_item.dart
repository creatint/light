import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show required;
import '../utils/utils.dart';

class FileItem extends StatefulWidget {
  FileItem(
      {@required this.file, @required this.onTap, @required this.onLongPress});

  final FileSystemEntity file;
  final ValueChanged<FileSystemEntity> onTap;
  final ValueChanged<FileSystemEntity> onLongPress;

  @override
  _FileItemState createState() => new _FileItemState();
}

class _FileItemState extends State<FileItem> {
  FileType type;

  Widget buildLeading() {
    type = getFileType(widget.file);
    IconData data;
    switch (type) {
      case FileType.TEXT:
      case FileType.PDF:
      case FileType.EPUB:
        data = Icons.book;
        break;
      case FileType.OTHER:
        data = Icons.insert_drive_file;
        break;
      case FileType.DIRECTORY:
        data = Icons.folder;
        break;
      case FileType.NOT_FOUND:
      default:
        data = Icons.do_not_disturb;
    }
    return new Icon(data);
  }

  @override
  Widget build(BuildContext context) {
    return new DecoratedBox(
      decoration: new BoxDecoration(
          border: new Border(
              bottom: new BorderSide(color: Colors.grey[200], width: 1.0))),
      child: new ListTile(
        leading: buildLeading(),
        title: new Text(
          getFileName(widget.file),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        onTap: () => widget.onTap(widget.file),
        onLongPress: () => widget.onLongPress(widget.file),
      ),
    );
  }
}
