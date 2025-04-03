import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:provider/provider.dart';

import '../services/gauth.dart';
import '../services/gdrive.dart';
import '../models/app_model.dart';
import '../widgets/tiles/file_tile.dart';
import '../widgets/tiles/folder_tile.dart';

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

  Future<void> _initAuthClient() async {
    String? selectedClientEmail = context.read<AppModel>().selectedClientEmail;
    GAuthService gauth = GAuthService(selectedClientEmail);
    AuthClient? authClient = await gauth.getServiceAccountClient();

    if (authClient != null) {
      context.read<AppModel>().authClient = authClient;
      _googleDriveService = GDriveService(client: authClient, context: context);
    }
  }

  Future<void> _loadFilesList({
    String? folderId,
    bool sharedWithMe = false,
    bool trashed = false,
  }) async {
    if (_googleDriveService != null) {
      await _googleDriveService!.listFiles(
        folderId: folderId ?? 'root',
        sharedWithMe: sharedWithMe,
        trashed: trashed,
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Files')),
      body: Consumer<AppModel>(
        builder: (context, model, child) {
          return model.files == null || model.files!.isEmpty
              ? Center(child: Text('No files available'))
              : ListView.builder(
                itemCount: model.files!.length,
                itemBuilder: (context, index) {
                  final file = model.files![index];
                  return file!.mimeType == 'application/vnd.google-apps.folder'
                      ? FolderTile(
                        file: file,
                        googleDriveService: _googleDriveService!,
                        loadFilesList: _loadFilesList,
                      )
                      : FileTile(file: file);
                },
              );
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
