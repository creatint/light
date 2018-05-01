import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show required;
import '../utils/utils.dart';

class FileItem extends StatefulWidget {
  FileItem({@required this.file});

  FileSystemEntity file;

  @override
  _FileItemState createState() => new _FileItemState();
}

class _FileItemState extends State<FileItem> {
  @override
  Widget build(BuildContext context) {
    return new DecoratedBox(
      decoration: new BoxDecoration(
          border: new Border(
              bottom: new BorderSide(color: Colors.grey[200], width: 1.0))),
      child: new ListTile(
        title: new Text(getFileName(widget.file)),
      ),
    );
  }
}
