import 'dart:io';
import 'dart:typed_data';

import 'package:chewie/chewie.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:manydrive/app/common/notification.dart';
import 'package:manydrive/app/models/file_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final FileModel fileModel;
  final List<FileModel>? allFiles;

  const VideoPlayerWidget({
    super.key,
    required this.fileModel,
    this.allFiles,
  });

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late PageController _pageController;
  List<FileModel> _videoFiles = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadVideoList();
  }

  Future<void> _loadVideoList() async {
    try {
      // Nếu có allFiles được truyền vào, lọc video từ đó
      if (widget.allFiles != null && widget.allFiles!.isNotEmpty) {
        _videoFiles = widget.allFiles!
            .where((file) => file.file.mimeType?.startsWith('video/') == true)
            .toList();
      } else {
        // Nếu không có, chỉ dùng video hiện tại
        _videoFiles = [widget.fileModel];
      }
      
      // Tìm index của video hiện tại
      _currentIndex = _videoFiles.indexWhere(
        (file) => file.file.id == widget.fileModel.file.id,
      );
      
      if (_currentIndex == -1) {
        _currentIndex = 0;
        _videoFiles = [widget.fileModel];
      }
      
      setState(() {
        _isLoading = false;
      });
      
      // Khởi tạo player cho video đầu tiên
      await _initializePlayer(_currentIndex);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _videoFiles = [widget.fileModel];
        _currentIndex = 0;
      });
      await _initializePlayer(0);
    }
  }

  Future<void> _initializePlayer(int index) async {
    try {
      // Dispose controller cũ nếu có
      if (_chewieController != null) {
        await _chewieController!.pause();
        _chewieController!.dispose();
        _chewieController = null;
      }
      
      // Chỉ dispose nếu đã được khởi tạo
      try {
        if (_videoPlayerController.value.isInitialized) {
          _videoPlayerController.dispose();
        }
      } catch (e) {
        // Controller chưa được khởi tạo, bỏ qua
      }

      final videoData = await _videoFiles[index].getBytes();
      final cacheKey = _videoFiles[index].file.id ?? _generateCacheKey(videoData);

      final cachedFile = await _getCachedVideo(cacheKey);

      if (cachedFile != null && await cachedFile.exists()) {
        _videoPlayerController = VideoPlayerController.file(cachedFile);
      } else {
        final savedFile = await _saveVideoToCache(cacheKey, videoData);
        _videoPlayerController = VideoPlayerController.file(savedFile);
      }

      _videoPlayerController.addListener(_checkVideoEnd);
      await _videoPlayerController.initialize();

      if (!mounted) return;

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
      if (mounted) {
        showErrorSnackBar(
          context,
          "Failed to initialize video player: $e",
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  // Tạo cache key từ hash của video data
  String _generateCacheKey(Uint8List data) {
    final hash = sha256.convert(data);
    return hash.toString();
  }

  // Lấy video từ cache nếu có
  Future<File?> _getCachedVideo(String cacheKey) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final videoDir = Directory('${cacheDir.path}/video_cache');

      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      final cachedFile = File('${videoDir.path}/$cacheKey.mp4');

      if (await cachedFile.exists()) {
        return cachedFile;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Lưu video vào cache
  Future<File> _saveVideoToCache(String cacheKey, Uint8List data) async {
    final cacheDir = await getTemporaryDirectory();
    final videoDir = Directory('${cacheDir.path}/video_cache');

    if (!await videoDir.exists()) {
      await videoDir.create(recursive: true);
    }

    final file = File('${videoDir.path}/$cacheKey.mp4');
    await file.writeAsBytes(data);

    return file;
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Vuốt sang phải (velocity > 0) -> video trước
          if (details.primaryVelocity! > 0) {
            _previousVideo();
          }
          // Vuốt sang trái (velocity < 0) -> video tiếp theo
          else if (details.primaryVelocity! < 0) {
            _nextVideo();
          }
        },
        child: Stack(
          children: [
            SafeArea(
              top: false,
              bottom: false,
              child: Center(
                child: _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : const CircularProgressIndicator(color: Colors.white),
              ),
            ),
            // Hiển thị indicator số video
            if (_videoFiles.length > 1)
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${_videoFiles.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _nextVideo() {
    if (_currentIndex < _videoFiles.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _initializePlayer(_currentIndex);
    }
  }

  void _previousVideo() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _initializePlayer(_currentIndex);
    }
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_checkVideoEnd);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
