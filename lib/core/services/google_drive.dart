import 'dart:typed_data';
import 'dart:io' as io;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:path_provider/path_provider.dart';
import './gapis_auth.dart';

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
      print("Lỗi khi danh sách file: $e");
    }
  }

  Future<void> downloadFile(String fileId, String fileName) async {
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

        print("Tải file thành công: $savePath");
      }
    } catch (e) {
      print("Lỗi khi tải file: $e");
    }
  }

  Future<void> uploadFile(String filePath) async {
    try {
      io.File file = io.File(filePath);
      var media = drive.Media(file.openRead(), file.lengthSync());

      var driveFile = drive.File()..name = file.uri.pathSegments.last;
      var response = await _driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );

      print("File đã tải lên Drive: ${response.name}, ID: ${response.id}");
    } catch (e) {
      print("Lỗi khi upload file: $e");
    }
  }

  void close() {
    _client.close();
  }
}
