import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:driveplus/common/show_notification.dart';

class GoogleDriveService {
  late AuthClient _client;
  late drive.DriveApi _driveApi;
  late BuildContext _context;

  List<drive.File> files = [];
  List<drive.File> trashed = [];
  List<drive.File> sharedWithMe = [];

  List<drive.File> get getFiles => files;
  List<drive.File> get getTrashed => trashed;
  List<drive.File> get getSharedWithMe => sharedWithMe;

  GoogleDriveService({
    required AuthClient client,
    required BuildContext context,
  }) {
    _context = context;
    initialize(client);
  }

  Future<void> initialize(AuthClient client) async {
    _client = client;
    _driveApi = drive.DriveApi(client);
  }

  Future<void> listFiles(String? folderId) async {
    try {
      if (folderId != null) {
        drive.FileList fileList = await _driveApi.files.list(
          q: "'$folderId' in parents",
        );
        files = fileList.files ?? [];
      } else {
        drive.FileList fileList = await _driveApi.files.list();
        files = fileList.files ?? [];
      }
    } catch (e) {
      showNotification(_context, 'Failed to list files: $e');
      throw Exception('Failed to list files: $e');
    }
  }

  Future<void> listTrashedFiles() async {
    try {
      drive.FileList fileList = await _driveApi.files.list(q: "trashed = true");
      trashed = fileList.files ?? [];
    } catch (e) {
      showNotification(_context, 'Failed to list trashed files: $e');
      throw Exception('Failed to list trashed files: $e');
    }
  }

  Future<void> listSharedWithMeFiles() async {
    try {
      drive.FileList fileList = await _driveApi.files.list(
        q: "sharedWithMe = true",
      );
      sharedWithMe = fileList.files ?? [];
    } catch (e) {
      showNotification(_context, 'Failed to list shared with me files: $e');
      throw Exception('Failed to list shared with me files: $e');
    }
  }

  Future<io.File?> downloadFile(String fileId, String fileName) async {
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

        final directory =
            await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
        String savePath = '${directory.path}/$fileName';
        io.File file = io.File(savePath);
        showProgressNotification(_context, fileName, 0 / 0);
        await file.writeAsBytes(bytes);

        return file;
      }

      return null;
    } catch (e) {
      showNotification(_context, 'Failed to download file: $e');
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
      showNotification(_context, 'Failed to upload file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<io.File> loadVideoToCache(String fileId, String fileName) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final cachePath = '${cacheDir.path}/$fileName';
      final cacheFile = io.File(cachePath);

      if (await cacheFile.exists()) {
        return cacheFile;
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
        return cacheFile;
      }
      showNotification(_context, 'Failed to load video: Media not found');
      throw Exception('Failed to load video: Media not found');
    } catch (e) {
      showNotification(_context, 'Failed to load video to cache: $e');
      throw Exception('Failed to load video to cache: $e');
    }
  }

  void close() {
    _client.close();
  }
}
