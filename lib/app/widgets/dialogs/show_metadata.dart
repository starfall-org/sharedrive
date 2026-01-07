import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';

import 'package:manydrive/app/models/file_model.dart';

void showMetadataDialog(BuildContext context, FileModel fileModel) async {
  File file = fileModel.file;
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Metadata'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${file.name}'),
              Text('ID: ${file.id}'),
              Text('Size: ${file.size} bytes'),
              Text('Created: ${file.createdTime}'),
              Text('Modified: ${file.modifiedTime}'),
              Text('MimeType: ${file.mimeType}'),
              Text('Description: ${file.description}'),
              Text('WebContentLink: ${file.webContentLink}'),
              Text('WebViewLink: ${file.webViewLink}'),
              Text('IconLink: ${file.iconLink}'),
              Text('ThumbnailLink: ${file.thumbnailLink}'),
            ],
          ),
        ),
  );
}
