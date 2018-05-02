import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/system.dart';
import '../widgets/file_item.dart';
import '../utils/utils.dart';

class ImportLocal extends StatefulWidget {
  @override
  _ImportLocalState createState() => _ImportLocalState();
}

class _ImportLocalState extends State<ImportLocal> {
  SystemService service = new SystemService();

  // is in select mode
  bool selectMode = false;

  bool scanned = false;

  FileType selectedType;

  /// current list of FileSystemEntityes
  Future<List<FileSystemEntity>> listFuture;

  List<FileSystemEntity> list = <FileSystemEntity>[];

  /// list of selected FileSystemEntities
  List<FileSystemEntity> selectedList = <FileSystemEntity>[];

  Directory currentDirectory;

  /// get entities in this path
  void resolvePath(FileSystemEntity directory,
      {List<FileSystemEntity> directories, bool recursive: false}) {
    if (null != directory) {
      currentDirectory = directory;
    }
    print('current directory is $currentDirectory');

    setState(() {
      listFuture = service.fileService.getEntities(directory,
          directories: directories, recursive: recursive);
    });
  }

  void update(FileSystemEntity file) {
    setState(() {
      if (indexOf(file) >= 0) {
        print('exists , remove');
        remove(file);
      } else {
        print('dose not exist , add');
        add(file);
      }
    });
  }

  void add(FileSystemEntity file) {
    remove(file);
    selectedList.add(file);
  }

  void remove(FileSystemEntity file) {
    if (selectedList.length == 0) return;
    selectedList.removeWhere((FileSystemEntity tmp) => tmp.path == file.path);
  }

  int indexOf(FileSystemEntity file) {
    if (selectedList.length == 0) return -1;
    return selectedList.indexWhere((FileSystemEntity tmp) {
      return tmp.path == file.path;
    });
  }

  /// handle tap
  void handleTap(FileSystemEntity file) {
    print('handle tap: $file');
    if (selectMode) {
      if (FileType.DIRECTORY == selectedType) {
        print('directory mode');
        if (FileSystemEntity.isDirectorySync(file.path)) {
          print('is directory');
          update(file);
        }
      } else {
        /// book mode
        print('book mode');
        if (FileSystemEntity.isDirectorySync(file.path)) {
          resolvePath(file);
        } else {
          print('is book');
          update(file);
        }
      }
    } else {
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
    if (!selectMode) {
      if (FileType.DIRECTORY == getFileType(file)) {
        selectedType = FileType.DIRECTORY;
      }
      selectMode = true;
      update(file);
    }
  }

  /// pop the current path
  void handlePop() {
    scanned = false;
    resolvePath(currentDirectory.parent);
  }

  void handleCancel() {
    setState(() {
      selectedList.clear();
      selectedType = null;
      selectMode = false;
    });
  }

  void handleSelectAll() {
    if (selectedList.length != list.length) {
      setState(() {
        selectedList.clear();
        list.forEach((FileSystemEntity file) {
          if (FileType.DIRECTORY == selectedType) {
            if (FileSystemEntity.isDirectorySync(file.path)) {
              selectedList.add(file);
            }
          } else {
            if (fileIsBook(file)) {
              selectedList.add(file);
            }
          }
        });
      });
    } else {
      setState(() {
        selectedList.clear();
      });
    }
  }

  /// handle scan files
  void handleScan() {
    if (!scanned) {
      if (FileType.DIRECTORY == selectedType) {
        /// directory mode
        if (selectedList.length > 0) {
          resolvePath(null, directories: selectedList, recursive: true);
        } else {
          resolvePath(currentDirectory, recursive: true);
        }
      } else {
        /// file mode
        resolvePath(currentDirectory, recursive: true);
      }
      setState(() {
        scanned = true;
        selectedType = null;
        selectMode = true;
      });
    } else {
      setState(() {
        scanned = false;
      });
      resolvePath(currentDirectory);
    }
  }

  void handleImport() async {
    if (selectMode &&
        FileType.DIRECTORY != selectedType &&
        selectedList.length > 0) {
      print('import ${selectedList.length} books.');
      int count = await service.bookService.importLocalBooks(selectedList);
      print('refresh shelf');
      service.send(['refreshShelf']);
      showDialog<bool>(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
                  title: new Text(count > 0 ? '成功导入$count个资源' : '导入失败'),
                  content: new Text('返回书架？',
                      style: Theme.of(context).textTheme.subhead),
                  actions: <Widget>[
                    new FlatButton(
                        child: const Text('否'),
                        onPressed: () {
                          Navigator.pop(context, false);
                        }),
                    new FlatButton(
                        child: const Text('是'),
                        onPressed: () {
                          Navigator.pop(context, true);
                        })
                  ])).then<bool>((value) {
        if (value) {
          Navigator.pop(context);
        } else {
//          handleCancleSelect();
        }
      });
    }
  }

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
                  softWrap: false,
                ),
              )),
              new Offstage(
                offstage: !service.fileService.canUp(currentDirectory),
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
              list = snapshot.data;
              list.removeWhere((FileSystemEntity file) =>
                  (scanned &&
                      (FileSystemEntity.isDirectorySync(file.path) ||
                          !fileIsBook(file))) ||
                  !scanned &&
                      ((!FileSystemEntity.isDirectorySync(file.path) &&
                          !fileIsBook(file))));
              return new ListView(
                  physics: new BouncingScrollPhysics(),
                  children: list.map((FileSystemEntity file) {
                    return new FileItem(
                      file: file,
                      onTap: handleTap,
                      selectMode: selectMode,
                      onLongPress: handleLongPress,
                      selectedList: selectedList,
                      indexOf: indexOf,
                      selectedType: selectedType,
                    );
                  }).toList());
            } else {
              return new Container(
                child: new Center(child: new Text('无结果')),
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
    return new Column(
      children: <Widget>[
        new Divider(height: 1.0),
        new Container(
          height: 48.0,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: new Center(
                        child: new Text('已选${selectedList.length}项')),
                  ),
                  new FlatButton(
                      onPressed: handleSelectAll, child: new Text('全选')),
                  new FlatButton(onPressed: handleCancel, child: new Text('取消'))
                ],
              ),
              new FlatButton(
                  onPressed: FileType.DIRECTORY != selectedType &&
                          selectedList.length > 0
                      ? handleImport
                      : null,
                  child: new Text('导入'))
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
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
            new SizedBox(
              width: 70.0,
              child: new FlatButton(
                  padding: EdgeInsets.zero,
                  onPressed: handleScan,
                  textColor: Theme.of(context).buttonColor,
                  child: new Text(!scanned ? '扫描' : '返回')),
            )
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
