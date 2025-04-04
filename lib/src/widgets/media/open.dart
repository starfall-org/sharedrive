  void _viewImage(
    BuildContext context,
    dynamic file,
    GDriveService googleDriveService,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: Text(file.name ?? 'Image Viewer')),
              body: FutureBuilder<Uint8List>(
                future: googleDriveService.loadFileToBytes(file.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading image: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    return Center(
                      child: Image.memory(snapshot.data ?? Uint8List(0)),
                    );
                  } else {
                    return const Center(child: Text('Failed to load image'));
                  }
                },
              ),
            ),
      ),
    );
  }

  void _playVideo(
    BuildContext context,
    dynamic file,
    GDriveService googleDriveService,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: Text(file.name ?? 'Video Player')),
              body: FutureBuilder<Uint8List>(
                future: googleDriveService.loadFileToBytes(file.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading video: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    return VideoPlayerWidget(
                      videoData: snapshot.data ?? Uint8List(0),
                    );
                  } else {
                    return const Center(child: Text('Failed to load video'));
                  }
                },
              ),
            ),
      ),
    );
  }

  void _playAudio(
    BuildContext context,
    dynamic file,
    GDriveService googleDriveService,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: Text(file.name ?? 'Audio Player')),
              body: FutureBuilder<Uint8List>(
                future: googleDriveService.loadFileToBytes(file.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading audio: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    return AudioPlayerWidget(
                      audioData: snapshot.data ?? Uint8List(0),
                    );
                  } else {
                    return const Center(child: Text('Failed to load audio'));
                  }
                },
              ),
            ),
      ),
    );
  }

  void _viewText(
    BuildContext context,
    dynamic file,
    GDriveService googleDriveService,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: Text(file.name ?? 'Text Viewer')),
              body: FutureBuilder<Uint8List>(
                future: googleDriveService.loadFileToBytes(file.id),
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