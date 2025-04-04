import 'dart:typed_data';
import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';

class FileModel {
  drive.DriveApi driveApi;
  String fileId;

  FileModel({required this.driveApi, required this.fileId});

  Future metadata({String additionalFields = ''}) async {
    try {
      var file = await driveApi.files.get(
        fileId,
        $fields: 'id,name,mimeType,size,modifiedTime,parents,$additionalFields',
      );
      return file;
    } catch (e) {
      throw Exception('Failed to get file: $e');
    }
  }

  Future<io.File?> download(String? fileName) async {
    try {
      var media = await driveApi.files.get(
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
        return file;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  Future<void> delete() async {
    try {
      await driveApi.files.delete(fileId);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<void> move(String newParentId) async {
    try {
      var driveFile =
          drive.File()
            ..id = fileId
            ..parents = [newParentId];
      await driveApi.files.update(driveFile, fileId);
    } catch (e) {
      throw Exception('Failed to move file: $e');
    }
  }

  Future<void> copy(String newParentId) async {
    try {
      var driveFile =
          drive.File()
            ..id = fileId
            ..parents = [newParentId];
      await driveApi.files.copy(driveFile, fileId);
    } catch (e) {
      throw Exception('Failed to copy file: $e');
    }
  }

  Future<void> createFolder(String folderName) async {
    try {
      var driveFile =
          drive.File()
            ..name = folderName
            ..mimeType = 'application/vnd.google-apps.folder';
      await driveApi.files.create(driveFile);
    } catch (e) {
      throw Exception('Failed to create folder: $e');
    }
  }

  Future<Uint8List> getBytes(String fileId) async {
    try {
      var media = await driveApi.files.get(
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
