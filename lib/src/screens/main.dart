import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/gdrive.dart';
import '../models/app_model.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/tiles/file_tile.dart';
import '../widgets/tiles/folder_tile.dart';
import '../widgets/video_player_widget.dart';

class MainScreen extends StatefulWidget {
  final String folderId;
  final bool isSharedWithMe;
  final bool isTrashed;

  const MainScreen({
    super.key,
    this.folderId = 'root',
    this.isSharedWithMe = false,
    this.isTrashed = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GDriveService? _googleDriveService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final authClient = context.read<AppModel>().authClient;
    if (authClient != null) {
      _googleDriveService = GDriveService(
        context: context,
        authClient: authClient,
      );
      await _loadFilesList(
        folderId: widget.folderId,
        sharedWithMe: widget.isSharedWithMe,
        trashed: widget.isTrashed,
      );
    }
    setState(() {
      _isInitialized = true;
    });
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

  void _openFile(BuildContext context, dynamic file) {
    final mimeType = file.mimeType ?? '';
    if (mimeType.startsWith('image/')) {
      _viewImage(context, file);
    } else if (mimeType.startsWith('video/')) {
      _playVideo(context, file);
    } else if (mimeType.startsWith('audio/')) {
      _playAudio(context, file);
    } else if (mimeType.startsWith('text/') || mimeType == 'application/json') {
      _viewText(context, file);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unsupported file type')));
    }
  }

  void _viewImage(BuildContext context, dynamic file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: Text(file.name)),
              body: Center(child: Image.network(file.webContentLink ?? '')),
            ),
      ),
    );
  }

  void _playVideo(BuildContext context, dynamic file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: Text(file.name)),
              body: Center(
                child: VideoPlayerWidget(videoUrl: file.webContentLink ?? ''),
              ),
            ),
      ),
    );
  }

  void _playAudio(BuildContext context, dynamic file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: Text(file.name)),
              body: Center(
                child: AudioPlayerWidget(audioUrl: file.webContentLink ?? ''),
              ),
            ),
      ),
    );
  }

  void _viewText(BuildContext context, dynamic file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: Text(file.name)),
              body: FutureBuilder<String>(
                future: _googleDriveService?.downloadFileAsString(file.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading file'));
                  } else {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(snapshot.data ?? ''),
                    );
                  }
                },
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
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
                  return GestureDetector(
                    onTap: () => _openFile(context, file),
                    child:
                        file!.mimeType == 'application/vnd.google-apps.folder'
                            ? folderTile(
                              context: context,
                              file: file,
                              loadFilesList: _loadFilesList,
                            )
                            : fileTile(context: context, file: file),
                  );
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
