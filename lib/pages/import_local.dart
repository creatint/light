import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/file.dart';
import '../widgets/file_item.dart';
import '../utils/utils.dart';

class ImportLocal extends StatefulWidget {
  @override
  _ImportLocalState createState() => _ImportLocalState();
}

class _ImportLocalState extends State<ImportLocal> {
  FileService fileService = new FileService();

  // is in select mode
  bool selectMode = false;

  /// current list of FileSystemEntityes
  Future<List<FileSystemEntity>> listFuture;

  /// list of selected FileSystemEntities
  List<FileSystemEntity> selectedList = <FileSystemEntity>[];

  Directory currentDirectory;

  /// get entities in this path
  void resolvePath(Directory directory) {
    currentDirectory = directory;
    print('current directory is $currentDirectory');
    setState(() {
      listFuture = fileService.getEntities(directory);
    });
  }

  /// handle tap
  void handleTap(FileSystemEntity file) {
    print('handle tap: $file');
    if (selectMode) {} else {
      if (FileSystemEntity.isDirectorySync(file.path)) {
        resolvePath(file);
      } else {
        print('点击的是文件');
      }
    }
  }

  /// handle long press
  void handleLongPress(FileSystemEntity file) {
    print('handle long press: $file');
  }

  /// pop the current path
  void handlePop() {
    resolvePath(currentDirectory.parent);
  }

  /// handle scan files
  void handleScan() {}

  Widget buildPathBar() {
    return new Column(
      children: <Widget>[
        new Container(
          height: 44.0,
          padding: const EdgeInsets.only(left: 14.0),
          child: new Row(
            children: <Widget>[
              new Expanded(
                  child: new Offstage(
                offstage: false,
                child: new Text(
                  currentDirectory?.path ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              )),
              new Offstage(
                offstage: !fileService.canUp(currentDirectory),
                child: new SizedBox(
                  height: 44.0,
                  child: new FlatButton(
                    child: new Text('上一级'),
                    textColor: Theme.of(context).primaryColor,
                    onPressed: handlePop,
                  ),
                ),
              )
            ],
          ),
        ),
        new Divider(height: 1.0)
      ],
    );
  }

  Widget buildContent() {
    return new FutureBuilder(
        future: listFuture,
        builder: (BuildContext context,
            AsyncSnapshot<List<FileSystemEntity>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return new Center(
              child: new Text('waiting...'),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && null != snapshot.data) {
              print('有值');
              print(snapshot.data);
              return new ListView(
                  children: snapshot.data.map((FileSystemEntity file) {
                return new FileItem(
                  file: file,
                  onTap: handleTap,
                  onLongPress: handleLongPress,
                );
              }).toList());
            } else {
              return new Container(
                child: new Text('无值，无权限'),
              );
            }
          } else {
            return new Container(
              child: new Text('异常'),
            );
          }
        });
  }

  Widget buildBottomBar() {
    return new Container(
      height: 48.0,
      child: new Row(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: new Text('已选0项'),
              ),
              new FlatButton(onPressed: () {}, child: new Text('全选')),
              new FlatButton(onPressed: () {}, child: new Text('取消'))
            ],
          ),
          new FlatButton(onPressed: () {}, child: new Text('导入'))
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
//    listFuture = fileService.getEntities(null);
    getExternalStorageDirectory().then((Directory directory) {
      resolvePath(directory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('导入本地书籍'),
          actions: <Widget>[
            new FlatButton(onPressed: handleScan, child: new Text('扫描'))
          ],
        ),
        body: new Column(
          children: <Widget>[
            buildPathBar(),
            new Expanded(
              child: buildContent(),
            ),
            new Offstage(
              offstage: !selectMode,
              child: buildBottomBar(),
            )
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
