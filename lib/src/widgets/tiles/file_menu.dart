import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:gsadrive/src/widgets/dialogs/show_metadata.dart';

import '../../services/gdrive.dart';

class FileMenuWidget extends StatefulWidget {
  final File file;
  final GDrive gds;

  const FileMenuWidget({super.key, required this.file, required this.gds});
  @override
  State<FileMenuWidget> createState() => _FileMenuState();
}

class _FileMenuState extends State<FileMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder:
          (context) => [
            PopupMenuItem(
              child: Text('Info'),
              onTap: () => _metadata(widget.file),
            ),
            PopupMenuItem(
              child: Text('Delete'),
              onTap: () => _delete(widget.file),
            ),
          ],
    );
  }

  void _metadata(File file) {
    try {
      showMetadataDialog(context, widget.gds.file(file.id!));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting file metadata: $e')),
      );
    }
  }

  void _delete(File file) {
    try {
      widget.gds.file(file.id!).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('File deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting file: $e')));
    }
  }
}
