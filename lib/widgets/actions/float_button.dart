import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/gdrive.dart';

class FloatButtons extends StatefulWidget {
  final GDrive gds;

  const FloatButtons({super.key, required this.gds});

  @override
  State<FloatButtons> createState() => _FloatButtonsState();
}

class _FloatButtonsState extends State<FloatButtons> {
  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String filePath = result.files.single.path ?? '';
      if (filePath.isNotEmpty) {
        await widget.gds.upload(filePath);
        widget.gds.refresh();
      }
    }
  }

  Future<void> _createFolder() async {
    TextEditingController folderController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create Folder"),
          content: TextField(
            controller: folderController,
            decoration: const InputDecoration(hintText: "Enter folder name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (folderController.text.isNotEmpty) {
                  await widget.gds.mkdir(folderController.text);
                  widget.gds.refresh();
                  Navigator.pop(context);
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: _createFolder,
          tooltip: 'Create Folder',
          child: const Icon(Icons.create_new_folder),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: _uploadFile,
          tooltip: 'Upload File',
          child: const Icon(Icons.upload_file),
        ),
      ],
    );
  }
}
