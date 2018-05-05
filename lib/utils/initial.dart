import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_permissions/simple_permissions.dart';
import '../services/system.dart';
import '../services/file.dart';
import '../utils/constants.dart';


/// initialize the app
Future<Null> initial() async {
  /// get instance of SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  /// get service instance
  SystemService service = new SystemService(prefs: prefs);

  /// get the fileService instance
  FileService fileService = new FileService(systemService: service);

  /// listen events
  service.listen((event) async {
    if (service.isAndroid) {
      if ('openSettings' == event[0]) {
        SimplePermissions.openSettings();
      } else if ('softUninstall' == event[0]) {
        print('soft uninstall');

        /// clear files
        String path = service.getString(app_path);
        if (null != path) {
          if (await fileService.deleteDirectory(path)) {
            print('delete path: $path successful');
          } else {
            print('delete path: $path failed');
          }
        }

        /// clear [SharedPreferences]
        service.setInt('launchTimes', null);
        service.setString(app_path, null);

        /// check install
        _checkInstall(service, fileService);
      }
    } else if (service.isIOS) {
      //TODO: listen events on iOS
    } else if (service.isFuchsia) {
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
    print('launch times is $launchTimes');
    launchTimes += 1;
    service.setInt('launchTimes', launchTimes);
  } else {
    /// set launch times to 1
    print('this is the first time to run the app');
    service.setInt('launchTimes', 1);
  }

  /// check and create root directory
  /// every time the app runs, do this
  if (!await fileService.checkAppDirectory()) {
    /// create root directory failed
    print('create root directory failed');
    return;
  }
  print('check root directory successful');

  /// store the root path.
  service.setString(app_path, fileService.appPath);
}
