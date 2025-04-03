import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';

import '../../services/gdrive.dart';
import '../media/audio.dart';
import '../media/video.dart';

Widget fileTile({
  required BuildContext context,
  required File file,
  required GDriveService googleDriveService,
}) {
  IconData fileIcon =
      file.mimeType?.startsWith('video/') == true
          ? Icons.video_file
          : Icons.insert_drive_file;
  return ListTile(
    leading: Icon(fileIcon),
    title: Text(file.name ?? 'Unnamed file'),
    onTap: () {
      /// openFile(context, file, googleDriveService);
    },
  );
}

void openFile(
  BuildContext context,
  File file,
  GDriveService googleDriveService,
) {
  final mimeType = file.mimeType ?? '';
  if (mimeType.startsWith('image/')) {
    _viewImage(context, file);
  } else if (mimeType.startsWith('video/')) {
    _playVideo(context, file);
  } else if (mimeType.startsWith('audio/')) {
    _playAudio(context, file);
  } else if (mimeType.startsWith('text/') || mimeType == 'application/json') {
    _viewText(context, file, googleDriveService);
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Unsupported file type')));
  }
}

void _viewImage(BuildContext context, dynamic file) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: Text(file.name)),
            body: Center(child: Image.network(file.webContentLink ?? '')),
          ),
    ),
  );
}

void _playVideo(BuildContext context, dynamic file) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: Text(file.name)),
            body: Center(
              child: VideoPlayerWidget(videoUrl: file.webContentLink ?? ''),
            ),
          ),
    ),
  );
}

void _playAudio(BuildContext context, dynamic file) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: Text(file.name)),
            body: Center(
              child: AudioPlayerWidget(audioUrl: file.webContentLink ?? ''),
            ),
          ),
    ),
  );
}

void _viewText(
  BuildContext context,
  dynamic file,
  GDriveService googleDriveService,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: Text(file.name)),
            body: FutureBuilder<String>(
              future: googleDriveService.downloadFileAsString(file.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading file'));
                } else {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(snapshot.data ?? ''),
                  );
                }
              },
            ),
          ),
    ),
  );
}
