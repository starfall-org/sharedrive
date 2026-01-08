import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:manydrive/app/models/file_model.dart';
import 'package:manydrive/app/services/gdrive.dart';
import 'package:manydrive/app/widgets/tiles/file_menu.dart';

enum SortType { name, date, size }

class FileListWidget extends StatefulWidget {
  final GDrive gds;
  final Function(FileModel, List<FileModel>) open;
  final String tabKey;
  final bool isSharedWithMe;
  final VoidCallback? onBackPressed;

  const FileListWidget({
    super.key,
    required this.gds,
    required this.open,
    required this.tabKey,
    required this.isSharedWithMe,
    this.onBackPressed,
  });

  @override
  State<FileListWidget> createState() => FileListWidgetState();
}

class FileListWidgetState extends State<FileListWidget> with AutomaticKeepAliveClientMixin {
  final GDrive gds = GDrive.instance;
  SortType _sortType = SortType.name;
  bool _sortAscending = true;

  @override
  bool get wantKeepAlive => true;

  // Public method để gọi từ parent
  void showSortMenu() {
    _showSortMenu();
  }

  @override
  void initState() {
    super.initState();
    // Load dữ liệu cho tab này khi khởi tạo
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Đợi frame tiếp theo để đảm bảo widget đã được mount
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    
    if (widget.isSharedWithMe) {
      await widget.gds.ls(sharedWithMe: true, tabKey: widget.tabKey);
    } else {
      await widget.gds.ls(tabKey: widget.tabKey);
    }
  }

  Widget folderTile({required FileModel fileModel, required List<FileModel> allFiles}) {
    File file = fileModel.file;
    IconData fileIcon = Icons.folder;
    Color backgroundColor =
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return ListTile(
      leading: Icon(fileIcon),
      trailing: FileMenuWidget(
        fileModel: fileModel,
        gds: widget.gds,
        tabKey: widget.tabKey,
      ),
      title: Text(file.name ?? 'Unnamed directory'),
      subtitle: Text(
        _formatDate(file.createdTime),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
      tileColor: backgroundColor,
      onTap: () => {widget.open(fileModel, allFiles)},
    );
  }

  Widget fileTile({required FileModel fileModel, required List<FileModel> allFiles}) {
    File file = fileModel.file;
    IconData fileIcon =
        file.mimeType?.startsWith('video/') == true
            ? Icons.video_file
            : file.mimeType?.startsWith('audio/') == true
            ? Icons.audiotrack
            : file.mimeType?.startsWith('image/') == true
            ? Icons.image
            : Icons.insert_drive_file;

    // Build thumbnail or icon
    Widget leadingWidget;
    if (file.thumbnailLink != null && file.thumbnailLink!.isNotEmpty) {
      leadingWidget = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: file.thumbnailLink!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 40,
            height: 40,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(fileIcon, size: 20),
          ),
          errorWidget: (context, url, error) => Icon(fileIcon),
        ),
      );
    } else {
      leadingWidget = Icon(fileIcon);
    }

    // Format subtitle with date and size
    String subtitle = _formatDate(file.modifiedTime ?? file.createdTime);
    if (file.size != null) {
      final size = int.tryParse(file.size!);
      if (size != null) {
        subtitle += ' • ${_formatFileSize(size)}';
      }
    }

    return ListTile(
      leading: leadingWidget,
      trailing: FileMenuWidget(
        fileModel: fileModel,
        gds: widget.gds,
        tabKey: widget.tabKey,
      ),
      title: Text(file.name ?? 'Unnamed file'),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
      onTap: () => {widget.open(fileModel, allFiles)},
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  List<FileModel> _sortFiles(List<FileModel> files) {
    final sorted = List<FileModel>.from(files);
    
    // Tách thư mục và file
    final folders = sorted.where((f) => 
      f.file.mimeType == 'application/vnd.google-apps.folder'
    ).toList();
    final regularFiles = sorted.where((f) => 
      f.file.mimeType != 'application/vnd.google-apps.folder'
    ).toList();
    
    // Sắp xếp thư mục
    _sortFileList(folders);
    // Sắp xếp file
    _sortFileList(regularFiles);
    
    // Ghép lại: thư mục trước, file sau
    return [...folders, ...regularFiles];
  }

  void _sortFileList(List<FileModel> files) {
    switch (_sortType) {
      case SortType.name:
        files.sort((a, b) {
          final comparison = (a.file.name ?? '').toLowerCase()
              .compareTo((b.file.name ?? '').toLowerCase());
          return _sortAscending ? comparison : -comparison;
        });
        break;
      case SortType.date:
        files.sort((a, b) {
          final dateA = a.file.modifiedTime ?? a.file.createdTime ?? DateTime(1970);
          final dateB = b.file.modifiedTime ?? b.file.createdTime ?? DateTime(1970);
          final comparison = dateA.compareTo(dateB);
          return _sortAscending ? comparison : -comparison;
        });
        break;
      case SortType.size:
        files.sort((a, b) {
          final sizeA = int.tryParse(a.file.size ?? '0') ?? 0;
          final sizeB = int.tryParse(b.file.size ?? '0') ?? 0;
          final comparison = sizeA.compareTo(sizeB);
          return _sortAscending ? comparison : -comparison;
        });
        break;
    }
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Sort by Name'),
              trailing: _sortType == SortType.name
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : null,
              onTap: () {
                setState(() {
                  if (_sortType == SortType.name) {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortType = SortType.name;
                    _sortAscending = true;
                  }
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Sort by Date'),
              trailing: _sortType == SortType.date
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : null,
              onTap: () {
                setState(() {
                  if (_sortType == SortType.date) {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortType = SortType.date;
                    _sortAscending = false; // Mới nhất trước
                  }
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_usage),
              title: const Text('Sort by Size'),
              trailing: _sortType == SortType.size
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : null,
              onTap: () {
                setState(() {
                  if (_sortType == SortType.size) {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortType = SortType.size;
                    _sortAscending = false; // Lớn nhất trước
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return StreamBuilder<List<FileModel>>(
      stream: widget.gds.getFilesListStream(widget.tabKey),
      initialData: const [],
      builder: (context, snapshot) {
        final fileModels = _sortFiles(snapshot.data ?? []);
        
        return fileModels.isEmpty
            ? Center(
                child: Text(
                  'No files',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: fileModels.length,
                itemBuilder: (context, index) {
                  final fileModel = fileModels[index];
                  return fileModel.file.mimeType ==
                          'application/vnd.google-apps.folder'
                      ? folderTile(fileModel: fileModel, allFiles: fileModels)
                      : fileTile(fileModel: fileModel, allFiles: fileModels);
                },
              );
      },
    );
  }
}
