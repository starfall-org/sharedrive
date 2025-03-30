import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:file_picker/file_picker.dart';
import '../core/services/google_drive.dart';

class DriveScreen extends StatefulWidget {
  const DriveScreen({super.key});

  @override
  State<DriveScreen> createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  late GoogleDriveService _googleDriveService;
  List<File> _files = [];

  @override
  void initState() {
    super.initState();
    _googleDriveService = GoogleDriveService();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    await _googleDriveService.initialize();
    await _googleDriveService.listFiles();

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
        _loadFiles();
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _files.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return ListTile(
                    title: Text(file.name ?? 'Unnamed file'),
                    subtitle: Text(file.id ?? 'No ID'),
                    onTap: () {},
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
