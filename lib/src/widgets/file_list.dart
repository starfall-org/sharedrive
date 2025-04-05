import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';

import '../models/file_model.dart';
import '../services/gdrive.dart';
import 'tiles/file_menu.dart';

class FileListWidget extends StatefulWidget {
  final List<FileModel> fileModels;
  final GDrive gds;
  final Function(FileModel) open;

  const FileListWidget({
    super.key,
    required this.fileModels,
    required this.gds,
    required this.open,
  });

  @override
  State<FileListWidget> createState() => _FileListState();
}

class _FileListState extends State<FileListWidget> {
  Widget folderTile({required FileModel fileModel}) {
    File file = fileModel.file;
    IconData fileIcon = Icons.folder;
    Color backgroundColor =
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return ListTile(
      leading: Icon(fileIcon),
      trailing: FileMenuWidget(fileModel: fileModel, gds: widget.gds),
      title: Text(file.name ?? 'Unnamed directory'),
      subtitle: Text(file.createdTime.toString()),
      tileColor: backgroundColor,
      onTap: () => {widget.open(fileModel)},
    );
  }

  Widget fileTile({required FileModel fileModel}) {
    File file = fileModel.file;
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
      onTap: () => {widget.open(fileModel)},
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.fileModels.isEmpty
        ? const Center(child: Text('No files available'))
        : ListView.builder(
          itemCount: widget.fileModels.length,
          itemBuilder: (context, index) {
            final fileModel = widget.fileModels[index];
            return fileModel.file.mimeType ==
                    'application/vnd.google-apps.folder'
                ? folderTile(fileModel: fileModel)
                : fileTile(fileModel: fileModel);
          },
        );
  }
}
