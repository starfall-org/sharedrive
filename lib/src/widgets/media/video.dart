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
  late final VideoPlayerController player;
  late final ChewieController controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      player = VideoPlayerController.contentUri(
        Uri.dataFromBytes(widget.videoData),
      );

      controller = ChewieController(
        videoPlayerController: player,
        aspectRatio:
            player.value.aspectRatio > 0 ? player.value.aspectRatio : 9 / 16,
      );
      player.addListener(_checkVideoEnd);
    } catch (e) {
      postNotification(context, "Failed to initialize player: $e");
    }
  }

  void _checkVideoEnd() {
    final isEnded = player.value.position >= player.value.duration;
    if (isEnded && player.value.isInitialized && !player.value.isPlaying) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: controller);
  }

  @override
  void dispose() {
    player.removeListener(_checkVideoEnd);
    player.dispose();
    controller.dispose();
    super.dispose();
  }
}
