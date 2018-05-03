import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show required;
import 'package:simple_permissions/simple_permissions.dart';
import 'system.dart';
import '../utils/constants.dart';

class FileService {
  static FileService _cache;

  factory FileService({SystemService systemService}) {
    if (null == _cache) {
      _cache = new FileService._internal(systemService: systemService);
    }
    return _cache;
  }

  FileService._internal({@required SystemService systemService});

  final SystemService service = new SystemService();

  Future<bool> createDirectory(String path, {bool recursive: false}) async {
    print('create directory path: $path');
    if (!await checkPermission()) {
      /// have no permission
      return false;
    }
    if (null == path) {
      /// path is null
      return false;
    }
    try {
      Directory direction = new Directory(path);
      if (direction.existsSync()) {
        /// path is exists
        return true;
      }
      direction.createSync(recursive: recursive);
      print('create directory [$path] successful');
      return true;
    } catch (e) {
      /// create directory failed.
      print('create directory [$path] failed e: $e');
      return false;
    }
  }

  /// app directory's path
  String appPath;

  /// when the app runs, check app directory if exists and create it.
  Future<bool> checkAppDirectory() async {
    print('check app directory');
    rootDirectory = await getExternalStorageDirectory();
    try {
      String path = join(rootDirectory.path, app_path);
      print('the app path is $path');
      if (await createDirectory(path)) {
        appPath = path;
        return true;
      }
      return false;
    } catch (e) {
      /// create root directory failed
      print('check app directory failed');
      return false;
    }
  }

  /// delete directory
  Future<bool> deleteDirectory(String path, {bool recursive: false}) async {
    if (!await checkPermission()) {
      /// have no permission
      return false;
    }
    if (null == path) {
      /// path is null
      return false;
    }
    try {
      Directory direction = new Directory(path);
      if (!direction.existsSync()) {
        /// path is not exists, return true directly
        return true;
      }
      direction.deleteSync(recursive: recursive);
      return true;
    } catch (e) {
      /// create directory failed.
      print('delete directory [$path] failed e: $e');
      return false;
    }
  }

  bool _havePermission = false;

  /// check directory permission
  Future<bool> checkPermission() async {
    if (service.isAndroid) {
      /// on android
      print('on android');
      print('check external directory permission');

      if (true == _havePermission) {
        print('have permission: $_havePermission');
        return _havePermission;
      }

      /// check write permission
      bool havePermission = await SimplePermissions
          .checkPermission(Permission.WriteExternalStorage);

      if (true == havePermission) {
        // have write permission
        print('have write permission');
        _havePermission = true;
      } else {
        /// have not wirte permission, request it
        print('have not write permission, request it');
        bool requestPermission = await SimplePermissions
            .requestPermission(Permission.WriteExternalStorage);
        if (true == requestPermission) {
          print('request external directroy permission successful.');
          _havePermission = true;
        } else {
          print('request external directroy permission failed.');
        }
      }
    } else if (service.isIOS) {
      /// TODO: check permission on iOS
      print('something need to be done on iOS');
    } else if (service.isFuchsia) {
      /// TODO: check permission on fuchsia
      print('something need to be done on Fuchsia');
    }
    return _havePermission;
  }

  Directory rootDirectory;

  /// valid only after checkAppDirectory has been called.
  bool canUp(FileSystemEntity currentEntity) {
    print('current: $currentEntity root: $rootDirectory ${currentEntity?.path !=
        rootDirectory.path}');
    return null != currentEntity &&
        currentEntity.path != rootDirectory.path &&
        currentEntity.path.length >= rootDirectory.path.length;
  }

  /// get FileSystemEntities from directory
  Future<List<FileSystemEntity>> getEntities(Directory directory,
      {List<FileSystemEntity> directories, bool recursive: false}) async {
    print('getEntities');
    if (!await checkPermission()) {
      print('get entities failed');
      return null;
    }
    if (null != directory &&
        directory.existsSync() &&
        FileSystemEntity.isDirectorySync(directory.path)) {
      /// signle directory
      return directory.listSync(recursive: recursive);
    }
    if (null != directories) {
      /// multi directories
      List<FileSystemEntity> list = <FileSystemEntity>[];
      directories.forEach((FileSystemEntity directory) async {
        List<FileSystemEntity> tmp = await getEntities(directory, recursive: recursive);
        if (null != tmp) {
          list.addAll(tmp);
        }
      });
      return list;
    }
    return null;
  }
}
