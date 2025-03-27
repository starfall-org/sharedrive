import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late BetterPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        aspectRatio: 16 / 9,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSubtitles: true,
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource.network(
        widget.videoUrl,
        videoFormat: BetterPlayerVideoFormat.hls,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer(controller: _controller),
    );
  }
}
