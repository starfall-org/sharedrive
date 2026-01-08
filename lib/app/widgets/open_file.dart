import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:manydrive/app/models/file_model.dart';
import 'package:manydrive/app/widgets/media/audio.dart';
import 'package:manydrive/app/widgets/media/video.dart';

class OpenFile {
  final BuildContext context;
  final FileModel fileModel;
  final List<FileModel>? allFiles;
  late File file;

  OpenFile({
    required this.context,
    required this.fileModel,
    this.allFiles,
  }) {
    file = fileModel.file;
  }

  void open() {
    if (file.mimeType?.startsWith('image/') == true) {
      _viewImage();
    } else if (file.mimeType?.startsWith('video/') == true) {
      _playVideo();
    } else if (file.mimeType?.startsWith('audio/') == true) {
      _playAudio();
    } else if (['application/json'].contains(file.mimeType) == true ||
        file.mimeType?.startsWith('text/') == true) {
      _viewText();
    }
  }

  void _viewImage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              body: FutureBuilder<Uint8List>(
                future: fileModel.getBytes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading image: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return Center(
                      child: Image.memory(snapshot.data ?? Uint8List(0)),
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                },
              ),
            ),
      ),
    );
  }

  void _playVideo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerWidget(
          fileModel: fileModel,
          allFiles: allFiles,
        ),
      ),
    );
  }

  void _playAudio() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              body: FutureBuilder<Uint8List>(
                future: fileModel.getBytes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading audio: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return AudioPlayerWidget(
                      audioData: snapshot.data ?? Uint8List(0),
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'Failed to load audio',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                },
              ),
            ),
      ),
    );
  }

  void _viewText() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              body: FutureBuilder<Uint8List>(
                future: fileModel.getBytes(),
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
}
