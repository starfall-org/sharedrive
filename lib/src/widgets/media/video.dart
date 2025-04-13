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

      _videoPlayerController.addListener(_checkVideoEnd);

      await _videoPlayerController.initialize();

      if (!mounted) return;

      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.position ==
            _videoPlayerController.value.duration) {
          setState(() {});
        }
      });

      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          aspectRatio:
              _videoPlayerController.value.aspectRatio > 0
                  ? _videoPlayerController.value.aspectRatio
                  : 9 / 16,
          autoPlay: true,
        );
      });
    } catch (e) {
      postNotification(context, "Failed to initialize player: $e");
    }
  }

  void _checkVideoEnd() {
    final controller = _videoPlayerController;
    if (!controller.value.isInitialized) return;

    final isEnded = controller.value.position >= controller.value.duration;
    final isNotPlaying = !controller.value.isPlaying;

    if (isEnded && isNotPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null) {
      return const Center(child: Text("Không thể phát video"));
    }

    return Chewie(controller: _chewieController!);
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_checkVideoEnd);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
