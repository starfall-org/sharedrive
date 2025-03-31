import 'dart:io' as io;
import 'package:driveplus/core/services/googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:driveplus/core/services/google_drive.dart';
import 'package:driveplus/common/video.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _DriveScreenState();
}

class _DriveScreenState extends State<FilesScreen> {
  late GoogleDriveService _googleDriveService;
  late AuthClient authClient;
  late io.File selectedFile;
  List<File> _files = [];

  @override
  void dispose() {
    _googleDriveService.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initAuthClient();
    _googleDriveService = GoogleDriveService(
      client: authClient,
      context: context,
    );
    _loadFilesList();
  }

  void _initAuthClient() async {
    authClient = await GapisAuth.getServiceAccountClient();
  }

  Future<void> _loadFilesList() async {
    await _googleDriveService.listFiles(null);

    setState(() {
      _files = _googleDriveService.files;
    });
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path ?? '';
      if (filePath.isNotEmpty) {
        await _googleDriveService.uploadFile(filePath);
        _loadFilesList();
      }
    } else {}
  }

  Future<void> _loadVideoToCache(File file) async {
    selectedFile = await _googleDriveService.loadVideoToCache(
      file.id ?? '',
      file.name ?? '',
    );
  }

  Widget _loadVideo(File file) {
    _loadVideoToCache(file);
    return Video(videoFile: selectedFile);
  }

  Widget directoryTile(File file) {
    return ListTile(
      leading: Icon(Icons.folder),
      trailing: Icon(Icons.arrow_forward_ios),
      title: Text(file.name ?? 'Unnamed directory'),
      subtitle: Text(file.mimeType ?? 'Unknown type'),
      onTap: () {
        _googleDriveService.listFiles(file.id);
        _loadFilesList();
      },
    );
  }

  Widget fileTile(File file) {
    var fileIcon =
        file.mimeType?.startsWith('video/') == true
            ? Icons.video_file
            : Icons.insert_drive_file;
    return ListTile(
      leading: Icon(fileIcon),
      title: Text(file.name ?? 'Unnamed file'),
      onTap: () {
        if (file.mimeType?.startsWith('video/') == true) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => _loadVideo(file)),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _files.isEmpty
              ? Center()
              : ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return file.mimeType == 'application/vnd.google-apps.folder'
                      ? directoryTile(file)
                      : fileTile(file);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadFile,
        tooltip: 'Upload File',
        child: Icon(Icons.upload_file),
      ),
    );
  }
}
