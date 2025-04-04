import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';

import '../services/gdrive.dart';
import 'tiles/file_menu.dart';

class FileListWidget extends StatefulWidget {
  final List<File> files;
  final GDrive gds;
  final Function open;

  const FileListWidget({
    super.key,
    required this.files,
    required this.gds,
    required this.open,
  });

  @override
  State<FileListWidget> createState() => _FileListState();
}

class _FileListState extends State<FileListWidget> {
  Widget folderTile({required File file}) {
    IconData fileIcon = Icons.folder;
    Color backgroundColor =
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return ListTile(
      leading: Icon(fileIcon),
      trailing: FileMenuWidget(file: file, gds: widget.gds),
      title: Text(file.name ?? 'Unnamed directory'),
      subtitle: Text(file.createdTime.toString()),
      tileColor: backgroundColor,
      onTap: () => {widget.open(file)},
    );
  }

  Widget fileTile({required File file}) {
    IconData fileIcon =
        file.mimeType?.startsWith('video/') == true
            ? Icons.video_file
            : file.mimeType?.startsWith('audio/') == true
            ? Icons.audiotrack
            : file.mimeType?.startsWith('image/') == true
            ? Icons.image
            : Icons.insert_drive_file;

    return ListTile(
      leading: Icon(fileIcon),
      title: Text(file.name ?? 'Unnamed file'),
      onTap: () => {widget.open(file)},
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.files.isEmpty
        ? const Center(child: Text('No files available'))
        : ListView.builder(
          itemCount: widget.files.length,
          itemBuilder: (context, index) {
            final file = widget.files[index];
            return file.mimeType == 'application/vnd.google-apps.folder'
                ? folderTile(file: file)
                : fileTile(file: file);
          },
        );
  }
}
