import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  final TextEditingController _urlController = TextEditingController();
  bool _isLandscape = false;
  List<String> _history = [];
  bool _showDrawer = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer(_urlController.text);
  }

  void _initializePlayer(String url) {
    if (url.isEmpty) return;

    _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
        _controller?.play();
        if (!_history.contains(url)) {
          _history.add(url);
        }
      });
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
      if (_isLandscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _urlController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _showUrlDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nhập URL Video'),
          content: TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              hintText: 'Nhập URL video vào đây',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                _initializePlayer(_urlController.text);
                Navigator.pop(context);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _showDrawer ? 250 : 0,
      color: Colors.black87,
      child:
          _showDrawer
              ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: _showUrlDialog,
                      icon: const Icon(Icons.add_link),
                      label: const Text('Thêm URL mới'),
                    ),
                  ),
                  const Divider(color: Colors.white30),
                  const Text(
                    'Lịch sử xem',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _history[index],
                            style: const TextStyle(color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _initializePlayer(_history[index]),
                        );
                      },
                    ),
                  ),
                ],
              )
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildDrawer(),
          Flexible(
            child: Stack(
              children: [
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[playerWidget()],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 10,
                  child: IconButton(
                    icon: Icon(
                      _showDrawer ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() => _showDrawer = !_showDrawer),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget playerWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double screenHeight = constraints.maxHeight;
        double videoWidth = screenWidth;
        double videoHeight = screenWidth / 16 * 9; // Mặc định tỷ lệ 16:9

        if (_controller != null && _controller!.value.isInitialized) {
          videoHeight = screenWidth / _controller!.value.aspectRatio;
          
          if (_isLandscape) {
            videoHeight = screenHeight;
            videoWidth = videoHeight * _controller!.value.aspectRatio;
            
            if (videoWidth > screenWidth) {
              videoWidth = screenWidth;
              videoHeight = screenWidth / _controller!.value.aspectRatio;
            }
          } else {
            if (videoHeight > screenHeight) {
              videoHeight = screenHeight;
              videoWidth = videoHeight * _controller!.value.aspectRatio;
            }
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: videoWidth,
              height: videoHeight,
              child: _controller != null && _controller!.value.isInitialized
                  ? VideoPlayer(_controller!)
                  : const Center(child: CircularProgressIndicator()),
            ),
            SizedBox(
              width: videoWidth,
              child: _controller != null 
                  ? VideoProgressIndicator(_controller!, allowScrubbing: true)
                  : const SizedBox(height: 4, child: LinearProgressIndicator()),
            ),
            SizedBox(
              width: videoWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.white),
                    onPressed: _controller != null ? () {
                      _controller!.seekTo(
                        _controller!.value.position - const Duration(seconds: 10),
                      );
                    } : null,
                  ),
                  IconButton(
                    icon: Icon(
                      _controller?.value.isPlaying == true ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: _controller != null ? () {
                      setState(() {
                        _controller!.value.isPlaying
                            ? _controller!.pause()
                            : _controller!.play();
                      });
                    } : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white),
                    onPressed: _controller != null ? () {
                      _controller!.seekTo(
                        _controller!.value.position + const Duration(seconds: 10),
                      );
                    } : null,
                  ),
                  IconButton(
                    icon: Icon(
                      _isLandscape ? Icons.screen_rotation : Icons.screen_lock_rotation,
                      color: Colors.white
                    ),
                    onPressed: _toggleOrientation,
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}