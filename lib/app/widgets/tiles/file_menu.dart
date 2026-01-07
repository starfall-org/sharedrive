import 'package:flutter/material.dart';
import 'package:manydrive/app/common/notification.dart';
import 'package:manydrive/app/models/file_model.dart';
import 'package:manydrive/app/services/gdrive.dart';
import 'package:manydrive/app/services/notification_service.dart';
import 'package:manydrive/app/widgets/dialogs/show_metadata.dart';

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
      showErrorSnackBar(
        context,
        'Error getting file metadata: $e',
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _delete() {
    try {
      widget.fileModel.delete();
      showSuccessSnackBar(
        context,
        'File deleted successfully',
      );
      widget.gds.refresh();
    } catch (e) {
      showErrorSnackBar(
        context,
        'Error deleting file: $e',
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _download() async {
    try {
      // Show SnackBar for immediate feedback
      showSnackBar(context, 'Starting download...', type: SnackBarType.info);
      
      // Perform download
      await widget.fileModel.download();
      
      // Show app notification when complete
      await NotificationService().showDownloadComplete(
        fileName: widget.fileModel.file.name ?? 'file',
        filePath: '/downloads/${widget.fileModel.file.name}',
      );
    } catch (e) {
      showErrorSnackBar(
        context,
        'Error downloading file: $e',
        duration: const Duration(seconds: 5),
      );
      
      await NotificationService().showError(
        title: 'Download Failed',
        message: 'Could not download ${widget.fileModel.file.name}',
      );
    }
  }
}
