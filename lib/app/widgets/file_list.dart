import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';

import 'package:manydrive/app/models/file_model.dart';
import 'package:manydrive/app/services/gdrive.dart';
import 'package:manydrive/app/widgets/tiles/file_menu.dart';

class FileListWidget extends StatefulWidget {
  final GDrive gds;
  final Function(FileModel) open;

  const FileListWidget({super.key, required this.gds, required this.open});

  @override
  State<FileListWidget> createState() => _FileListState();
}

class _FileListState extends State<FileListWidget> {
  final GDrive gds = GDrive.instance;

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
      trailing: FileMenuWidget(fileModel: fileModel, gds: widget.gds),
      title: Text(file.name ?? 'Unnamed file'),
      onTap: () => {widget.open(fileModel)},
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FileModel>>(
      stream: widget.gds.filesListStream,
      builder: (context, snapshot) {
        final fileModels = snapshot.data ?? [];
        return Scaffold(
          appBar:
              widget.gds.pathHistory.isEmpty ||
                      widget.gds.pathHistory.last == 'shared'
                  ? null
                  : AppBar(
                    leading: BackButton(onPressed: () => widget.gds.rollback()),
                  ),
          body: ListView.builder(
            itemCount: fileModels.length,
            itemBuilder: (context, index) {
              final fileModel = fileModels[index];
              return fileModel.file.mimeType ==
                      'application/vnd.google-apps.folder'
                  ? folderTile(fileModel: fileModel)
                  : fileTile(fileModel: fileModel);
            },
          ),
        );
      },
    );
  }
}
