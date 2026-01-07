import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:manydrive/app/models/file_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        keyName = 'root';
        // Không thêm vào pathHistory nếu đang về root
      } else if (folderId != null) {
        conditions.add("'$folderId' in parents");
        keyName = folderId;
        // Chỉ thêm vào pathHistory nếu chưa có hoặc khác với path cuối cùng
        if (pathHistory.isEmpty || pathHistory.last != folderId) {
          pathHistory.add(folderId);
        }
      }

      if (sharedWithMe) {
        conditions.add("sharedWithMe = true");
        keyName = 'shared';
        // Reset pathHistory khi chuyển sang tab "Shared with me"
        pathHistory.clear();
        pathHistory.add('shared');
      }

      if (trashed) {
        conditions.add("trashed = true");
        keyName = 'trashed';
        // Reset pathHistory khi chuyển sang tab "Trashed"
        pathHistory.clear();
        pathHistory.add('trashed');
      }

      String query = conditions.join(" and ");
      currentQuery = query;

      _filesListController.add(_cachedFiles[keyName] ??= []);

      // Load from cache first (offline support)
      final cachedData = await _loadCachedFileList(keyName);
      if (cachedData != null) {
        _cachedFiles[keyName] = cachedData;
        _filesListController.add(cachedData);
      }

      var response = await _driveApi.files.list(
        q: query.isNotEmpty ? query : null,
        $fields: 'files(id,name,mimeType,size,createdTime,modifiedTime,thumbnailLink,iconLink,webContentLink,webViewLink,description)',
      );
      List<FileModel> files = [];
      for (var file in response.files ?? []) {
        files.add(FileModel(driveApi: _driveApi, file: file));
      }

      _cachedFiles[keyName] = files;
      _filesListController.add(files);
      
      // Save to persistent cache
      await _saveCachedFileList(keyName, files);
    } catch (e) {
      // If offline, use cached data
      final cachedData = await _loadCachedFileList(keyName);
      if (cachedData != null) {
        _cachedFiles[keyName] = cachedData;
        _filesListController.add(cachedData);
      } else {
        throw Exception('Failed to list files: $e');
      }
    }
  }

  Future<void> rollback() async {
    if (pathHistory.isNotEmpty) {
      pathHistory.removeLast();
      if (pathHistory.isNotEmpty) {
        String lastPath = pathHistory.last;
        if (lastPath == 'shared') {
          await ls(sharedWithMe: true);
        } else if (lastPath == 'trashed') {
          await ls(trashed: true);
        } else {
          await ls(folderId: lastPath);
        }
      } else {
        await ls(); // Quay về thư mục gốc
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

  Future<void> _saveCachedFileList(String key, List<FileModel> files) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> fileJsonList = files.map((fileModel) {
        return {
          'id': fileModel.file.id,
          'name': fileModel.file.name,
          'mimeType': fileModel.file.mimeType,
          'size': fileModel.file.size,
          'createdTime': fileModel.file.createdTime?.toIso8601String(),
          'modifiedTime': fileModel.file.modifiedTime?.toIso8601String(),
          'thumbnailLink': fileModel.file.thumbnailLink,
          'iconLink': fileModel.file.iconLink,
          'webContentLink': fileModel.file.webContentLink,
          'webViewLink': fileModel.file.webViewLink,
          'description': fileModel.file.description,
        };
      }).toList();
      
      await prefs.setString('cached_files_$key', jsonEncode(fileJsonList));
    } catch (e) {
      // Ignore cache save errors
    }
  }

  Future<List<FileModel>?> _loadCachedFileList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedJson = prefs.getString('cached_files_$key');
      
      if (cachedJson == null) return null;
      
      final List<dynamic> fileJsonList = jsonDecode(cachedJson);
      return fileJsonList.map((json) {
        final file = drive.File()
          ..id = json['id']
          ..name = json['name']
          ..mimeType = json['mimeType']
          ..size = json['size']
          ..createdTime = json['createdTime'] != null ? DateTime.parse(json['createdTime']) : null
          ..modifiedTime = json['modifiedTime'] != null ? DateTime.parse(json['modifiedTime']) : null
          ..thumbnailLink = json['thumbnailLink']
          ..iconLink = json['iconLink']
          ..webContentLink = json['webContentLink']
          ..webViewLink = json['webViewLink']
          ..description = json['description'];
        
        return FileModel(driveApi: _driveApi, file: file);
      }).toList();
    } catch (e) {
      return null;
    }
  }
}
