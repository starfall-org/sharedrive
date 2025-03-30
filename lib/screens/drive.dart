import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mediaplus/core/services/google_drive.dart';
import 'package:mediaplus/common/alert.dart';
import 'package:mediaplus/widgets/video.dart';

class DriveScreen extends StatefulWidget {
  const DriveScreen({super.key});

  @override
  State<DriveScreen> createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  late GoogleDriveService _googleDriveService;
  List<File> _files = [];

  String _selectedFileUri = '';

  @override
  void dispose() {
    _googleDriveService.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _googleDriveService = GoogleDriveService();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      await _googleDriveService.initialize();
      await _googleDriveService.listFiles();
    } catch (e) {
      Alert.show(e.toString(), context);
    }

    setState(() {
      _files = _googleDriveService.files;
    });
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path ?? '';
      if (filePath.isNotEmpty) {
        try {
          await _googleDriveService.uploadFile(filePath);
          _loadFiles();
        } catch (e) {
          Alert.show(e.toString(), context);
        }
      }
    } else {}
  }

  Future<void> _loadVideoToCache(File file) async {
    try {
      _selectedFileUri = await _googleDriveService.loadVideoToCache(
        file.id ?? '',
        file.name ?? '',
      );
    } catch (e) {
      Alert.show(e.toString(), context);
    }
  }

  Widget _loadVideo(File file) {
    _loadVideoToCache(file);
    return Video(videoUrl: _selectedFileUri);
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
                  return ListTile(
                    title: Text(file.name ?? 'Unnamed file'),
                    subtitle: Text(file.id ?? 'No ID'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _loadVideo(file),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadFile,
        child: Icon(Icons.upload_file),
        tooltip: 'Upload File',
      ),
    );
  }
}
