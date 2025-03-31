import 'dart:io' as io;

import 'package:driveplus/common/video.dart';
import 'package:driveplus/core/services/google_drive.dart';
import 'package:driveplus/core/services/googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

class ShareWithMeScreen extends StatefulWidget {
  const ShareWithMeScreen({super.key});

  @override
  State<ShareWithMeScreen> createState() => _ScreenState();
}

class _ScreenState extends State<ShareWithMeScreen> {
  late GoogleDriveService _googleDriveService;
  late AuthClient authClient;
  late io.File selectedFile;
  List<File> _files = [];

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
    await _googleDriveService.listSharedWithMeFiles();

    setState(() {
      _files = _googleDriveService.files;
    });
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
    );
  }
}
