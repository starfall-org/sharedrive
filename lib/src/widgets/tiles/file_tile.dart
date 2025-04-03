import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';

class FileTile extends StatelessWidget {
  final File file;
  const FileTile({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
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
}
