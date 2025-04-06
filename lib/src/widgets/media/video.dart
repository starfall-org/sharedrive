import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import '../../common/notification.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Uint8List videoData;

  const VideoPlayerWidget({super.key, required this.videoData});

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.contentUri(
        Uri.dataFromBytes(widget.videoData),
      );

      if (!mounted) return;

      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          aspectRatio:
              _videoPlayerController.value.aspectRatio > 0
                  ? _videoPlayerController.value.aspectRatio
                  : 9 / 16,
          autoInitialize: true,
          showControls: true,
          autoPlay: true,
          showControlsOnInitialize: true,
        );
      });
    } catch (e) {
      postNotification(context, "Failed to initialize player: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: _chewieController!);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
