import 'dart:convert';
import 'dart:typed_data';

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
          : file.mimeType?.startsWith('audio/') == true
          ? Icons.audiotrack
          : file.mimeType?.startsWith('image/') == true
          ? Icons.image
          : Icons.insert_drive_file;

  return ListTile(
    leading: Icon(fileIcon),
    title: Text(file.name ?? 'Unnamed file'),
    trailing: PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'delete') {
          _deleteFile(context, file, googleDriveService);
        }
      },
      itemBuilder: (BuildContext context) {
        return [PopupMenuItem<String>(value: 'delete', child: Text('Delete'))];
      },
    ),
    onTap: () => openFile(context, file, googleDriveService),
  );
}

void _deleteFile(
  BuildContext context,
  File file,
  GDriveService googleDriveService,
) async {
  try {
    await googleDriveService.deleteFile(file.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('File deleted successfully')));
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error deleting file: $e')));
  }
}

void openFile(
  BuildContext context,
  File file,
  GDriveService googleDriveService,
) {
  final mimeType = file.mimeType ?? '';
  if (mimeType.startsWith('image/')) {
    _viewImage(context, file, googleDriveService);
  } else if (mimeType.startsWith('video/')) {
    _playVideo(context, file, googleDriveService);
  } else if (mimeType.startsWith('audio/')) {
    _playAudio(context, file, googleDriveService);
  } else if (mimeType.startsWith('text/') || mimeType == 'application/json') {
    _viewText(context, file, googleDriveService);
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Unsupported file type')));
  }
}

void _viewImage(
  BuildContext context,
  dynamic file,
  GDriveService googleDriveService,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: Text(file.name ?? 'Image Viewer')),
            body: FutureBuilder<Uint8List>(
              future: googleDriveService.loadFileToBytes(file.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading image: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  return Center(
                    child: Image.memory(snapshot.data ?? Uint8List(0)),
                  );
                } else {
                  return const Center(child: Text('Failed to load image'));
                }
              },
            ),
          ),
    ),
  );
}

void _playVideo(
  BuildContext context,
  dynamic file,
  GDriveService googleDriveService,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: Text(file.name ?? 'Video Player')),
            body: FutureBuilder<Uint8List>(
              future: googleDriveService.loadFileToBytes(file.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading video: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  return VideoPlayerWidget(
                    videoData: snapshot.data ?? Uint8List(0),
                  );
                } else {
                  return const Center(child: Text('Failed to load video'));
                }
              },
            ),
          ),
    ),
  );
}

void _playAudio(
  BuildContext context,
  dynamic file,
  GDriveService googleDriveService,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: Text(file.name ?? 'Audio Player')),
            body: FutureBuilder<Uint8List>(
              future: googleDriveService.loadFileToBytes(file.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading audio: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  return AudioPlayerWidget(
                    audioData: snapshot.data ?? Uint8List(0),
                  );
                } else {
                  return const Center(child: Text('Failed to load audio'));
                }
              },
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
            appBar: AppBar(title: Text(file.name ?? 'Text Viewer')),
            body: FutureBuilder<Uint8List>(
              future: googleDriveService.loadFileToBytes(file.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading file: ${snapshot.error}'),
                  );
                } else {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: SelectableText(
                      utf8.decode(snapshot.data ?? Uint8List(0)),
                    ),
                  );
                }
              },
            ),
          ),
    ),
  );
}
