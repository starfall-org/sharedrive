import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';

import '../../services/gdrive.dart';

Widget folderTile({
  required BuildContext context,
  required File file,
  required Function loadFilesList,
  required GDriveService googleDriveService,
}) {
  IconData fileIcon = Icons.folder;
  Color backgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest;
  
  return ListTile(
    leading: Icon(fileIcon),
    trailing: PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'delete') {
          _deleteFolder(context, file, googleDriveService);
        }
      },
      itemBuilder: (BuildContext context) {
        return [PopupMenuItem<String>(value: 'delete', child: Text('Delete'))];
      },
    ),
    title: Text(file.name ?? 'Unnamed directory'),
    subtitle: Text(file.createdTime.toString()),
    tileColor: backgroundColor,
    onTap: () async {
      await loadFilesList(folderId: file.id);
    },
  );
}

void _deleteFolder(
  BuildContext context,
  File file,
  GDriveService googleDriveService,
) async {
  try {
    await googleDriveService.deleteFile(file.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Folder deleted successfully')));
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error deleting folder: $e')));
  }
}
