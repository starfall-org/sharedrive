import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';

Widget folderTile({
  required BuildContext context,
  required File file,
  required Function loadFilesList,
}) {
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
      await loadFilesList(folderId: file.id);
    },
  );
}
