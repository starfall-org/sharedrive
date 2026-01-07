import 'dart:async';
import 'dart:io' as io;

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:manydrive/app/models/file_model.dart';

class GDrive {
  static final _instance = GDrive._internal();
  static GDrive get instance => _instance;

  final _filesListController = StreamController<List<FileModel>>.broadcast();
  Stream<List<FileModel>> get filesListStream => _filesListController.stream;

  bool isLoggedIn = false;
  late drive.DriveApi _driveApi;
  final Map<String, List<FileModel>> _cachedFiles = {};
  String currentQuery = "'root' in parents";
  String keyName = 'root';
  final List<String> pathHistory = [];

  GDrive._internal();

  Future<void> login(AuthClient authClient) async {
    _driveApi = drive.DriveApi(authClient);
    isLoggedIn = true;
  }

  Future<void> ls({
    String? folderId,
    bool sharedWithMe = false,
    bool trashed = false,
  }) async {
    if (!isLoggedIn) {
      return;
    }

    try {
      List<String> conditions = [];

      if (folderId == null && !sharedWithMe && !trashed) {
        conditions.add("'root' in parents");
      } else if (folderId != null) {
        conditions.add("'$folderId' in parents");
        keyName = folderId;
        pathHistory.add(folderId);
      }

      if (sharedWithMe) {
        conditions.add("sharedWithMe = true");
        keyName = 'shared';
        pathHistory.add('shared');
      }

      if (trashed) {
        conditions.add("trashed = true");
        keyName = 'trashed';
        pathHistory.add('trashed');
      }

      String query = conditions.join(" and ");
      currentQuery = query;

      _filesListController.add(_cachedFiles[keyName] ??= []);

      var response = await _driveApi.files.list(
        q: query.isNotEmpty ? query : null,
      );
      List<FileModel> files = [];
      for (var file in response.files ?? []) {
        files.add(FileModel(driveApi: _driveApi, file: file));
      }

      _cachedFiles[keyName] = files;
      _filesListController.add(files);
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  Future<void> rollback() async {
    if (pathHistory.isNotEmpty) {
      pathHistory.removeLast();
      if (pathHistory.isNotEmpty) {
        await ls(folderId: pathHistory.last);
      } else {
        await ls();
      }
    }
  }

  Future<void> refresh() async {
    var response = await _driveApi.files.list(q: currentQuery);
    List<FileModel> files = [];
    for (var file in response.files ?? []) {
      files.add(FileModel(driveApi: _driveApi, file: file));
    }

    _cachedFiles[keyName] = files;
    _filesListController.add(files);
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
