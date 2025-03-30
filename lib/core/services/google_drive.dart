import 'dart:typed_data';
import 'dart:io' as io;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:mediaplus/core/services/gapis_auth.dart';

class GoogleDriveService {
  late AuthClient _client;
  late drive.DriveApi _driveApi;
  List<drive.File> files = [];

  GoogleDriveService();

  Future<void> initialize() async {
    _client = await GapisAuth.getAuthClient();
    _driveApi = drive.DriveApi(_client);
  }

  Future<void> listFiles() async {
    try {
      drive.FileList fileList = await _driveApi.files.list();
      files = fileList.files ?? [];
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  Future downloadFile(String fileId, String fileName) async {
    try {
      var media = await _driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );

      if (media is drive.Media) {
        Uint8List bytes = await media.stream.fold<Uint8List>(
          Uint8List(0),
          (previous, element) => Uint8List.fromList([...previous, ...element]),
        );

        final directory = await getApplicationDocumentsDirectory();
        String savePath = '${directory.path}/$fileName';
        io.File file = io.File(savePath);
        await file.writeAsBytes(bytes);
        return savePath;
      }
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  Future<void> uploadFile(String filePath) async {
    try {
      io.File file = io.File(filePath);
      var media = drive.Media(file.openRead(), file.lengthSync());
      var driveFile = drive.File()..name = file.uri.pathSegments.last;
      await _driveApi.files.create(driveFile, uploadMedia: media);
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<String> loadVideoToCache(String fileId, String fileName) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final cachePath = '${cacheDir.path}/$fileName';
      final cacheFile = io.File(cachePath);

      if (await cacheFile.exists()) {
        return 'file://${cacheFile.path}';
      }

      var media = await _driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );

      if (media is drive.Media) {
        Uint8List bytes = await media.stream.fold<Uint8List>(
          Uint8List(0),
          (previous, element) => Uint8List.fromList([...previous, ...element]),
        );

        await cacheFile.writeAsBytes(bytes);
        return 'file://${cacheFile.path}';
      }
      throw Exception('Failed to load video: Media not found');
    } catch (e) {
      throw Exception('Failed to load video to cache: $e');
    }
  }

  void close() {
    _client.close();
  }
}
