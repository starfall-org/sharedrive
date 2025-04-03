import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';

Widget fileTile({required BuildContext context, required File file}) {
  IconData fileIcon =
      file.mimeType?.startsWith('video/') == true
          ? Icons.video_file
          : Icons.insert_drive_file;
  return ListTile(
    leading: Icon(fileIcon),
    title: Text(file.name ?? 'Unnamed file'),
    onTap: () {},
  );
}
