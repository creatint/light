import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show required;
import '../utils/utils.dart';

class FileItem extends StatefulWidget {
  FileItem(
      {@required this.file,
      @required this.onTap,
      @required this.onLongPress,
      @required this.selectMode,
      @required this.selectedList,
      @required this.indexOf,
      @required this.selectedType});

  final FileSystemEntity file;
  final ValueChanged<FileSystemEntity> onTap;
  final ValueChanged<FileSystemEntity> onLongPress;

  final bool selectMode;

  /// list of selected FileSystemEntities
  final List<FileSystemEntity> selectedList;

  final ValuePipe<FileSystemEntity, int> indexOf;

  final FileType selectedType;

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
      case FileType.IMAGE:
        data = Icons.image;
        break;
      case FileType.VIDEO:
        data = Icons.video_library;
        break;
      case FileType.AUDIO:
        data = Icons.audiotrack;
        break;
      case FileType.NOT_FOUND:
      default:
        data = Icons.do_not_disturb;
    }
    return new Icon(data);
  }

  bool checkSelected() {
    return widget.indexOf(widget.file) >= 0;
  }

  bool get trailOffstage =>
      !widget.selectMode ||
      !((FileType.DIRECTORY == widget.selectedType &&
              FileSystemEntity.isDirectorySync(widget.file.path)) ||
          (FileType.DIRECTORY != widget.selectedType &&
              !FileSystemEntity.isDirectorySync(widget.file.path)));

  Widget buildTailing() {
    IconData iconData;
    Color color;
    if (checkSelected()) {
      iconData = Icons.check_circle;
      color = Theme.of(context).accentColor;
    } else {
      iconData = Icons.radio_button_unchecked;
      color = Theme.of(context).disabledColor;
    }
    return new Offstage(
      offstage: trailOffstage,
      child: new Icon(
        iconData,
        color: color,
      ),
    );
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
          onLongPress: widget.selectMode && trailOffstage
              ? null
              : () => widget.onLongPress(widget.file),
          trailing: buildTailing()),
    );
  }
}
