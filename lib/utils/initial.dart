import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:simple_permissions/simple_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../services/system.dart';
import '../services/file.dart';
import '../utils/constants.dart';

/// initialize the app
Future<Null> initial() async {
  /// get instance of SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  /// get service instance
  SystemService service = new SystemService(prefs: prefs);

  FileService fileService = new FileService();

  /// listen events
  service.listen((event) async {
    if (TargetPlatform.android == service.platform) {
      if ('requestPermission' == event[0]) {
        if (null != event[2])
          event[2](SimplePermissions.requestPermission(event[1]));
        else
          SimplePermissions.requestPermission(event[1]);
      } else if ('checkPermission' == event[0]) {
        if (null != event[2])
          event[2](SimplePermissions.checkPermission(event[1]));
        else
          SimplePermissions.checkPermission(event[1]);
      } else if ('getPermissionStatus' == event[0]) {
        if (null != event[2])
          event[2](SimplePermissions.getPermissionStatus(event[1]));
        else
          SimplePermissions.getPermissionStatus(event[1]);
      } else if ('openSettings' == event[0]) {
        SimplePermissions.openSettings();
      } else if ('softUninstall' == event[0]) {
        print('soft uninstall');

        /// clear files
        String path = service.getString(root_name);
        if (null != path) {
          if (await fileService.deleteDirectory(path)) {
            print('delete path: $path successful');
          } else {
            print('delete path: $path failed');
          }
        }

        /// clear [SharedPreferences]
        service.setInt('launchTimes', null);
        service.setString(root_name, null);

        /// check install
        _checkInstall(service, fileService);
      }
    } else if (TargetPlatform.iOS == service.platform) {
      //TODO: listen events on iOS
    } else if (TargetPlatform.fuchsia == service.platform) {
      //TODO: listen events on fuchsia
    }
  });

  /// check install
  _checkInstall(service, fileService);
}

/// check install
/// if launch times is bigger then 1, return directly;
/// if is null or smaller then 1, try to create directory - [root_name]
Future<Null> _checkInstall(
    SystemService service, FileService fileService) async {
  int launchTimes = service.getInt('launchTimes');
  if (null != launchTimes && launchTimes > 0) {
    /// update launch times
    print('lancun times is $launchTimes');
    launchTimes += 1;
    service.setInt('launchTimes', launchTimes);
    return;
  } else {
    /// set launch times to 1
    print('this is the first time to run the app');
    service.setInt('launchTimes', 1);
  }

  /// create root directory
  if (!await fileService.creatRootDirectory()) {
    /// create root directory failed
    return;
  }

  /// store the root path.
  service.setString(root_name, fileService.rootPath);
}
