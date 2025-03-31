import 'package:permission_handler/permission_handler.dart';

Future<void> checkAndRequestPermissions() async {
  Map<Permission, PermissionStatus> statuses =
      await [Permission.notification, Permission.storage].request();

  if (statuses[Permission.notification] != PermissionStatus.granted) {
    await Permission.notification.request();
  }

  if (statuses[Permission.storage] != PermissionStatus.granted) {
    await Permission.storage.request();
  }
}

Future<bool> hasRequiredPermissions() async {
  final notification = await Permission.notification.status;
  final storage = await Permission.storage.status;

  return notification.isGranted && storage.isGranted;
}
