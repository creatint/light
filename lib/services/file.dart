import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, required;
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

  /// root directory's path
  String rootPath;

  Future<bool> creatRootDirectory() async {
    print('create root directory');
    try {
      String path = join((await getExternalStorageDirectory()).path, root_name);
      print('the root path is $path');
      if (await createDirectory(path)) {
        rootPath = path;
        return true;
      }
      return false;
    } catch (e) {
      /// create root directory failed
      print('create root directory failed');
      return false;
    }
  }

  Future<Directory> getRootDirectory() async {
    if (null != rootPath) {
      return new Directory(rootPath);
    }
    return null;
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
    if (TargetPlatform.android == service.platform) {
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
        _havePermission = havePermission;
      } else {
        /// have not wirte permission, request it
        print('have not write permission, request it');
        bool requestPermission = await SimplePermissions
            .requestPermission(Permission.WriteExternalStorage);
        if (true == requestPermission) {
          print('request external directroy permission successful.');
          _havePermission = havePermission;
        } else {
          print('request external directroy permission failed.');
        }
      }
    } else if (TargetPlatform.iOS == service.platform) {
      /// TODO: check permission on iOS
      print('something need to be done on iOS');
    } else if (TargetPlatform.fuchsia == service.platform) {
      /// TODO: check permission on fuchsia
      print('something need to be done on Fuchsia');
    }
    return _havePermission;
  }

  /// get FileSystemEntities from directory
  Future<List<FileSystemEntity>> getEntities(dynamic directory,
      {bool recursive: false}) async {
    if (!await checkPermission()) {
      return null;
    }
    if (null == directory) {
      directory = await getExternalStorageDirectory();
    }
    if (directory is String) {
      directory = new Directory(directory);
    }
    if (!directory.existsSync()) {
      return null;
    }
    print('get Entities $directory');

    return directory.listSync(recursive: recursive);
  }
}
