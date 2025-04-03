import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';

import '../../services/gdrive.dart';

class FolderTile extends StatelessWidget {
  final File file;
  final GDriveService googleDriveService;
  final Function loadFilesList;
  const FolderTile({
    super.key,
    required this.file,
    required this.googleDriveService,
    required this.loadFilesList,
  });

  @override
  Widget build(BuildContext context) {
    IconData fileIcon =
        file.mimeType?.startsWith('video/') == true
            ? Icons.video_file
            : Icons.insert_drive_file;
    return ListTile(
      leading: Icon(fileIcon),
      trailing: Icon(Icons.arrow_forward_ios),
      title: Text(file.name ?? 'Unnamed directory'),
      subtitle: Text(file.mimeType ?? 'Unknown type'),
      onTap: () async {
        await googleDriveService.listFiles(folderId: file.id);
        await loadFilesList();
      },
    );
  }
}
