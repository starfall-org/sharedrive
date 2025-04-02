import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';

import '../../settings/video.dart';
import '../../common/notification.dart';

class VideoPlayerWidget extends StatefulWidget {
  final File videoFile;

  const VideoPlayerWidget({super.key, required this.videoFile});

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (widget.videoFile.path.isEmpty) {
      postNotification(context, "Video is empty");
      return;
    }

    final videoSettings = context.watch<VideoSettingsNotifier>();

    try {
      _videoPlayerController = VideoPlayerController.file(widget.videoFile);

      await _videoPlayerController.initialize();

      if (!mounted) return;

      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          aspectRatio:
              _videoPlayerController.value.aspectRatio > 0
                  ? _videoPlayerController.value.aspectRatio
                  : 9 / 16,
          showControls: true,
          autoPlay: videoSettings.autoPlay,
          looping: videoSettings.looping,
          showControlsOnInitialize: true,
          fullScreenByDefault: videoSettings.fullscreenByDefault,
          additionalOptions:
              (context) => <OptionItem>[
                OptionItem(
                  onTap:
                      (_) => videoSettings.autoPlay = !videoSettings.autoPlay,
                  iconData:
                      videoSettings.autoPlay ? Icons.autorenew : Icons.pause,
                  title:
                      videoSettings.autoPlay
                          ? "Disable autoplay"
                          : "Enable autoplay",
                ),
                OptionItem(
                  onTap: (_) => videoSettings.looping = !videoSettings.looping,
                  iconData:
                      videoSettings.looping ? Icons.repeat : Icons.repeat_one,
                  title:
                      videoSettings.looping
                          ? "Disable looping"
                          : "Enable looping",
                ),
                OptionItem(
                  onTap:
                      (_) =>
                          videoSettings.fullscreenByDefault =
                              !videoSettings.fullscreenByDefault,
                  iconData:
                      videoSettings.fullscreenByDefault
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen,
                  title:
                      videoSettings.fullscreenByDefault
                          ? "Disable fullscreen by default"
                          : "Enable fullscreen by default",
                ),
              ],
        );
        _isInitializing = false;
      });
    } catch (e) {
      postNotification(context, "Failed to initialize player: $e");
      setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_chewieController == null) {
      return const Center(child: Text("Không thể phát video"));
    }

    return Chewie(controller: _chewieController!);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
