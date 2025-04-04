import 'dart:io' as io;

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';

import '../models/file_model.dart';

class GDrive {
  static final _instance = GDrive._internal();
  static GDrive get instance => _instance;

  late drive.DriveApi _driveApi;

  GDrive._internal();

  Future<void> init(AuthClient authClient) async {
    _driveApi = drive.DriveApi(authClient);
  }

  Future<List<FileModel>> ls({
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
      if (trashed) {
        conditions.add("trashed = true");
      }

      String query = conditions.join(" and ");

      var response = await _driveApi.files.list(
        q: query.isNotEmpty ? query : null,
      );
      List<FileModel> files = [];
      for (var file in response.files ?? []) {
        files.add(FileModel(driveApi: _driveApi, file: file));
      }
      return files;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  Future<void> upload(String filePath) async {
    try {
      io.File file = io.File(filePath);
      var media = drive.Media(file.openRead(), file.lengthSync());
      var driveFile = drive.File()..name = file.uri.pathSegments.last;
      await _driveApi.files.create(driveFile, uploadMedia: media);
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> mkdir(String folderName) async {
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
}
