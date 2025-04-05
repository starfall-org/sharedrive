import 'package:flutter/material.dart';
import 'package:gsadrive/src/widgets/dialogs/show_metadata.dart';

import '../../models/file_model.dart';
import '../../services/gdrive.dart';

class FileMenuWidget extends StatefulWidget {
  final FileModel fileModel;
  final GDrive gds;

  const FileMenuWidget({super.key, required this.fileModel, required this.gds});
  @override
  State<FileMenuWidget> createState() => _FileMenuState();
}

class _FileMenuState extends State<FileMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder:
          (context) => [
            PopupMenuItem(child: Text('Download'), onTap: () => _download()),
            PopupMenuItem(child: Text('Info'), onTap: () => _metadata()),
            PopupMenuItem(child: Text('Delete'), onTap: () => _delete()),
          ],
    );
  }

  void _metadata() {
    try {
      showMetadataDialog(context, widget.fileModel);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting file metadata: $e')),
      );
    }
  }

  void _delete() {
    try {
      widget.fileModel.delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('File deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting file: $e')));
    }
  }

  void _download() {
    try {
      widget.fileModel.download();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error downloading file: $e')));
    }
  }
}
