import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

import '../services/gauth.dart';
import '../services/gdrive.dart';
import '../settings/credentials.dart';

class MainScreen extends StatefulWidget {
  final String? folderId;
  final bool isSharedWithMe;
  final bool isTrashed;

  const MainScreen({
    super.key,
    this.folderId,
    this.isSharedWithMe = false,
    this.isTrashed = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GDriveService? _googleDriveService;
  AuthClient? authClient;
  List<File> _files = [];

  @override
  void initState() {
    super.initState();
    _initAuthClient();
    _loadFilesList(
      folderId: widget.folderId,
      sharedWithMe: widget.isSharedWithMe,
      trashed: widget.isTrashed,
    );
  }

  @override
  void dispose() {
    _googleDriveService?.close();
    super.dispose();
  }

  Future<void> _initAuthClient() async {
    CredentialsSettings credentialsSettings = CredentialsSettings();
    String? selectedClientEmail = credentialsSettings.clientEmail;
    GAuthService gauth = GAuthService(selectedClientEmail);
    authClient = await gauth.getServiceAccountClient();
    if (authClient != null) {
      _googleDriveService = GDriveService(
        client: authClient!,
        context: context,
      );
    }
  }

  Future<void> _loadFilesList({
    String? folderId,
    bool sharedWithMe = false,
    bool trashed = false,
  }) async {
    if (_googleDriveService != null) {
      await _googleDriveService!.listFiles(
        folderId: folderId,
        sharedWithMe: sharedWithMe,
        trashed: trashed,
      );

      setState(() {
        _files = _googleDriveService!.files;
      });
    }
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String filePath = result.files.single.path ?? '';
      if (filePath.isNotEmpty) {
        await _googleDriveService?.uploadFile(filePath);
        await _loadFilesList();
      }
    }
  }

  Future<void> _createFolder() async {
    TextEditingController folderController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create Folder"),
          content: TextField(
            controller: folderController,
            decoration: InputDecoration(hintText: "Enter folder name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (folderController.text.isNotEmpty) {
                  await _googleDriveService?.createFolder(
                    folderController.text,
                  );
                  await _loadFilesList();
                  Navigator.pop(context);
                }
              },
              child: Text("Create"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFileTile(File file) {
    IconData fileIcon =
        file.mimeType?.startsWith('video/') == true
            ? Icons.video_file
            : Icons.insert_drive_file;
    return ListTile(
      leading: Icon(fileIcon),
      title: Text(file.name ?? 'Unnamed file'),
      onTap: () {},
    );
  }

  Widget _buildDirectoryTile(File file) {
    return ListTile(
      leading: Icon(Icons.folder),
      trailing: Icon(Icons.arrow_forward_ios),
      title: Text(file.name ?? 'Unnamed directory'),
      subtitle: Text(file.mimeType ?? 'Unknown type'),
      onTap: () async {
        await _googleDriveService?.listFiles(folderId: file.id);
        await _loadFilesList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Files')),
      body:
          _files.isEmpty
              ? Center(child: Text('No files available'))
              : ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return file.mimeType == 'application/vnd.google-apps.folder'
                      ? _buildDirectoryTile(file)
                      : _buildFileTile(file);
                },
              ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _createFolder,
            tooltip: 'Create Folder',
            child: Icon(Icons.create_new_folder),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _uploadFile,
            tooltip: 'Upload File',
            child: Icon(Icons.upload_file),
          ),
        ],
      ),
    );
  }
}
