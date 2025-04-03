import 'dart:typed_data';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../common/notification.dart';
import '../models/app_model.dart';

class GDriveService {
  late BuildContext context;
  late AuthClient authClient;
  late drive.DriveApi _driveApi;

  GDriveService({required this.context, required this.authClient}) {
    initialize();
  }

  Future<void> initialize() async {
    _driveApi = drive.DriveApi(authClient);
  }

  Future<void> listFiles({
    String? folderId,
    bool sharedWithMe = false,
    bool trashed = false,
  }) async {
    try {
      List<String> conditions = [];

      if (folderId != null) {
        conditions.add("'$folderId' in parents");
      }

      if (sharedWithMe) {
        conditions.add("sharedWithMe = true");
      }

      conditions.add("trashed = $trashed");

      String query = conditions.join(" and ");

      drive.FileList fileList = await _driveApi.files.list(
        q: query.isNotEmpty ? query : null,
      );

      context.read<AppModel>().files = fileList.files;
    } catch (e) {
      throw Exception('Failed to list files: $e');
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
        await file.writeAsBytes(bytes);
        postNotification(context, 'Downloaded file: $fileName');
        return file;
      }

      return null;
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

  Future<void> deleteFile(String? fileId) async {
    try {
      await _driveApi.files.delete(fileId!);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<void> createFolder(String folderName) async {
    try {
      var driveFile =
          drive.File()
            ..name = folderName
            ..mimeType = 'application/vnd.google-apps.folder';
      await _driveApi.files.create(driveFile);
    } catch (e) {
      throw Exception('Failed to create folder: $e');
    }
  }

  Future<Uint8List> loadFileToBytes(String fileId) async {
    try {
      var media = await _driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );

      if (media is drive.Media) {
        final buffer = <int>[];
        await for (var chunk in media.stream) {
          buffer.addAll(chunk);
        }

        return Uint8List.fromList(buffer);
      }

      throw Exception('Failed to load file: Media not found');
    } catch (e) {
      throw Exception('Failed to load file to bytes: $e');
    }
  }
}
