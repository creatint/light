import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:simple_permissions/simple_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../services/system.dart';

/// initialize the app
Future<Null> initial() async {
  /// get instance of SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  /// get service instance
  SystemService service = new SystemService(prefs: prefs);

  /// listen events
  service.listen((event) {
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

        /// clear data
        String path = service.getString('path');
        if ('/storage/emulated/0/Yotaku' == path) {
          try {
            new Directory(path)..deleteSync(recursive: true);
            print('delete path: $path successful');
          } catch(e) {
            print('delete path: $path failed, e: $e');
          }
        }
        service.setInt('launchTimes', null);
        service.setString('path', null);

        /// check install
        _checkInstall(service);
      }
    } else if (TargetPlatform.iOS == service.platform) {
      //TODO: listen events on iOS
    } else if (TargetPlatform.fuchsia == service.platform) {
      //TODO: listen events on fuchsia
    }
  });

  /// check install
  _checkInstall(service);
}

/// check install
/// if launch times is bigger then 1, return directly;
/// if is null or smaller then 1, try to create directory - Yotaku
Future<Null> _checkInstall(SystemService service) async {
  int launchTimes = service.getInt('launchTimes');
  if (null != launchTimes && launchTimes > 0) {
    /// update launch times
    print('lancun times is $launchTimes');
    launchTimes += 1;
    service.setInt('launchTimes', launchTimes);
    return;
  }

  if (TargetPlatform.android == service.platform) {
    /// this is on android
    print('on android');

    /// set launch times to 1
    service.setInt('launchTimes', 1);

    print('this is the first time to run the app');

    /// check write permission
    bool havePermission =
    await SimplePermissions.checkPermission(Permission.WriteExternalStorage);
    if (true == havePermission) {
      // have write permission
      print('have write permission');
    } else {
      /// have not wirte permission, request it
      print('have not write permission, request it');
      bool result = await SimplePermissions
          .requestPermission(Permission.WriteExternalStorage);
      if (true != result) {
        print('request wirte permission failed.');
        return;
      }
      print('request wirte permission successful.');
    }

    /// create Yotaku directory
    try {
      Directory rootDirectory = await getExternalStorageDirectory();
      print('rootDirectory is $rootDirectory');
      String path = join(rootDirectory.path, 'Yotaku');
      print('target path is $path');

      service.setString('path', path);

      Directory yotaku = new Directory(path);

      /// path exists, return
      if (yotaku.existsSync()) {
        print('${yotaku.path} exists, return');
        return;
      }

      /// path not exists, create it
      yotaku.createSync();
    } catch (e) {
      print('get rootDirectory failed, e: $e');
      return;
    }
  } else if (TargetPlatform.iOS == service.platform) {
    /// TODO:iOS
    print('something need to be done on iOS');
  }
}
