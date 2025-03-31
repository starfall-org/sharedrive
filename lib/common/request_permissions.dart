import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<void> checkAndRequestPermissions() async {
  if (Platform.isAndroid) {
    if (await Permission.notification.isDenied &&
        Platform.version.startsWith('13')) {
      await Permission.notification.request();
    }

    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }
  }
}
