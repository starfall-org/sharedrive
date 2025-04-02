import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/media/video.dart';

class Video extends StatefulWidget {
  final File videoFile;

  const Video({super.key, required this.videoFile});

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  late File videoFile;

  @override
  void initState() {
    super.initState();
    videoFile = widget.videoFile;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _restoreUI();
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: VideoPlayerWidget(videoFile: videoFile),
        onEndDrawerChanged: (isOpened) {
          if (!isOpened) {
            _restoreUI();
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _restoreUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
