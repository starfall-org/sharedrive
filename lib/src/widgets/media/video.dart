import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import '../../common/notification.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitializing = true;
  bool _autoPlay = false;
  bool _looping = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

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
          autoPlay: _autoPlay,
          looping: _looping,
          showControlsOnInitialize: true,

          additionalOptions:
              (context) => <OptionItem>[
                OptionItem(
                  onTap:
                      (_) => setState(() {
                        _autoPlay = !_autoPlay;
                      }),
                  iconData: _autoPlay ? Icons.autorenew : Icons.pause,
                  title: _autoPlay ? "Disable autoplay" : "Enable autoplay",
                ),
                OptionItem(
                  onTap:
                      (_) => setState(() {
                        _looping = !_looping;
                      }),
                  iconData: _looping ? Icons.repeat : Icons.repeat_one,
                  title: _looping ? "Disable looping" : "Enable looping",
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
