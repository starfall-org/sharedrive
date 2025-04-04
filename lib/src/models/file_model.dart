import 'dart:typed_data';
import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/drive/v3.dart';
import 'package:path_provider/path_provider.dart';

class FileModel {
  final drive.DriveApi driveApi;
  final File file;

  FileModel({required this.driveApi, required this.file});

  Future metadata({String additionalFields = ''}) async {}

  Future<io.File?> download() async {
    try {
      var media = await driveApi.files.get(
        file.id!,
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
        String savePath = '${directory.path}/${file.name}';
        io.File fileIo = io.File(savePath);
        await fileIo.writeAsBytes(bytes);
        return fileIo;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  Future<void> delete() async {
    try {
      await driveApi.files.delete(file.id!);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<void> move(String newParentId) async {
    try {
      var driveFile =
          drive.File()
            ..id = file.id!
            ..parents = [newParentId];
      await driveApi.files.update(driveFile, file.id!);
    } catch (e) {
      throw Exception('Failed to move file: $e');
    }
  }

  Future<void> copy(String newParentId) async {
    try {
      var driveFile =
          drive.File()
            ..id = file.id!
            ..parents = [newParentId];
      await driveApi.files.copy(driveFile, file.id!);
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

  Future<Uint8List> getBytes() async {
    try {
      var media = await driveApi.files.get(
        file.id!,
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
