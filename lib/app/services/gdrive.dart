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

  // Mỗi tab có stream riêng
  final Map<String, StreamController<List<FileModel>>> _filesListControllers = {};
  
  Stream<List<FileModel>> getFilesListStream(String tabKey) {
    if (!_filesListControllers.containsKey(tabKey)) {
      _filesListControllers[tabKey] = StreamController<List<FileModel>>.broadcast();
    }
    return _filesListControllers[tabKey]!.stream;
  }

  bool isLoggedIn = false;
  late drive.DriveApi _driveApi;
  final Map<String, List<FileModel>> _cachedFiles = {};
  
  // Mỗi tab có pathHistory riêng
  final Map<String, List<String>> _pathHistories = {};
  
  List<String> getPathHistory(String tabKey) {
    return _pathHistories[tabKey] ?? [];
  }

  GDrive._internal();

  Future<void> login(AuthClient authClient) async {
    _driveApi = drive.DriveApi(authClient);
    isLoggedIn = true;
  }

  Future<void> ls({
    String? folderId,
    bool sharedWithMe = false,
    bool trashed = false,
    required String tabKey,
    bool isRollback = false,
  }) async {
    if (!isLoggedIn) {
      return;
    }

    // Khởi tạo pathHistory cho tab nếu chưa có
    if (!_pathHistories.containsKey(tabKey)) {
      _pathHistories[tabKey] = [];
    }

    // Khởi tạo stream controller cho tab nếu chưa có
    if (!_filesListControllers.containsKey(tabKey)) {
      _filesListControllers[tabKey] = StreamController<List<FileModel>>.broadcast();
    }

    try {
      List<String> conditions = [];
      String keyName;

      if (folderId == null && !sharedWithMe && !trashed) {
        conditions.add("'root' in parents");
        keyName = '${tabKey}_root';
        // Reset pathHistory khi về root
        _pathHistories[tabKey] = [];
      } else if (folderId != null) {
        conditions.add("'$folderId' in parents");
        keyName = '${tabKey}_$folderId';
        // Chỉ thêm vào pathHistory nếu không phải rollback và chưa có hoặc khác với path cuối cùng
        if (!isRollback && (_pathHistories[tabKey]!.isEmpty || _pathHistories[tabKey]!.last != folderId)) {
          _pathHistories[tabKey]!.add(folderId);
        }
      } else if (sharedWithMe) {
        conditions.add("sharedWithMe = true");
        keyName = '${tabKey}_shared';
        // Reset pathHistory cho tab shared
        _pathHistories[tabKey] = [];
      } else {
        conditions.add("trashed = true");
        keyName = '${tabKey}_trashed';
        // Reset pathHistory cho tab trashed
        _pathHistories[tabKey] = [];
      }

      String query = conditions.join(" and ");

      // Emit cached data first
      _filesListControllers[tabKey]!.add(_cachedFiles[keyName] ?? []);

      // Load from persistent cache (offline support)
      final cachedData = await _loadCachedFileList(keyName);
      if (cachedData != null) {
        _cachedFiles[keyName] = cachedData;
        _filesListControllers[tabKey]!.add(cachedData);
      }

      // Fetch from API
      var response = await _driveApi.files.list(
        q: query.isNotEmpty ? query : null,
        $fields: 'files(id,name,mimeType,size,createdTime,modifiedTime,thumbnailLink,iconLink,webContentLink,webViewLink,description)',
      );
      List<FileModel> files = [];
      for (var file in response.files ?? []) {
        files.add(FileModel(driveApi: _driveApi, file: file));
      }

      _cachedFiles[keyName] = files;
      _filesListControllers[tabKey]!.add(files);
      
      // Save to persistent cache
      await _saveCachedFileList(keyName, files);
    } catch (e) {
      // If offline, use cached data
      String keyName = folderId != null 
          ? '${tabKey}_$folderId' 
          : sharedWithMe 
              ? '${tabKey}_shared' 
              : trashed 
                  ? '${tabKey}_trashed' 
                  : '${tabKey}_root';
      
      final cachedData = await _loadCachedFileList(keyName);
      if (cachedData != null) {
        _cachedFiles[keyName] = cachedData;
        _filesListControllers[tabKey]!.add(cachedData);
      } else {
        throw Exception('Failed to list files: $e');
      }
    }
  }

  Future<void> rollback(String tabKey) async {
    if (!_pathHistories.containsKey(tabKey) || _pathHistories[tabKey]!.isEmpty) {
      return;
    }

    _pathHistories[tabKey]!.removeLast();
    
    if (_pathHistories[tabKey]!.isNotEmpty) {
      String lastPath = _pathHistories[tabKey]!.last;
      await ls(folderId: lastPath, tabKey: tabKey, isRollback: true);
    } else {
      // Quay về root hoặc shared tùy theo tab
      if (tabKey == 'shared') {
        await ls(sharedWithMe: true, tabKey: tabKey, isRollback: true);
      } else {
        await ls(tabKey: tabKey, isRollback: true);
      }
    }
  }

  Future<void> refresh(String tabKey) async {
    // Lấy pathHistory của tab hiện tại
    final pathHistory = _pathHistories[tabKey] ?? [];
    
    if (pathHistory.isEmpty) {
      // Refresh root hoặc shared tùy theo tab
      if (tabKey == 'shared') {
        await ls(sharedWithMe: true, tabKey: tabKey, isRollback: true);
      } else {
        await ls(tabKey: tabKey, isRollback: true);
      }
    } else {
      // Refresh thư mục hiện tại
      String currentPath = pathHistory.last;
      await ls(folderId: currentPath, tabKey: tabKey, isRollback: true);
    }
  }

  Future<void> upload(
    String filePath,
    String tabKey, {
    Function(int)? onProgress,
  }) async {
    try {
      io.File file = io.File(filePath);
      final fileSize = await file.length();
      
      // Tạo stream với progress tracking
      Stream<List<int>> progressStream = file.openRead().transform(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) {
            sink.add(data);
            if (onProgress != null) {
              // Tính progress (đơn giản hóa, không chính xác 100%)
              onProgress(data.length);
            }
          },
        ),
      );
      
      var media = drive.Media(progressStream, fileSize);
      var driveFile = drive.File()..name = file.uri.pathSegments.last;
      
      // Lấy thư mục hiện tại của tab
      final pathHistory = _pathHistories[tabKey] ?? [];
      if (pathHistory.isNotEmpty) {
        driveFile.parents = [pathHistory.last];
      }
      
      await _driveApi.files.create(driveFile, uploadMedia: media);
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> mkdir(String folderName, String tabKey) async {
    try {
      var driveFile =
          drive.File()
            ..name = folderName
            ..mimeType = 'application/vnd.google-apps.folder';
      
      // Lấy thư mục hiện tại của tab
      final pathHistory = _pathHistories[tabKey] ?? [];
      if (pathHistory.isNotEmpty) {
        driveFile.parents = [pathHistory.last];
      }
      
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
