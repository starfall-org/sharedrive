import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  return status.isGranted;
}

Future<bool> requestStoragePermission() async {
  final status = await Permission.storage.request();
  return status.isGranted;
}

Future<bool> requestLocationPermission() async {
  final status = await Permission.location.request();
  return status.isGranted;
}

Future<bool> requestMicrophonePermission() async {
  final status = await Permission.microphone.request();
  return status.isGranted;
}

Future<bool> requestContactsPermission() async {
  final status = await Permission.contacts.request();
  return status.isGranted;
}

Future<bool> requestNotificationPermission() async {
  final status = await Permission.notification.request();
  return status.isGranted;
}

Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
  List<Permission> permissions,
) async {
  return await permissions.request();
}

Future<bool> checkPermissionStatus(Permission permission) async {
  final status = await permission.status;
  return status.isGranted;
}

Future<bool> openAppSettings() async {
  return await openAppSettings();
}
