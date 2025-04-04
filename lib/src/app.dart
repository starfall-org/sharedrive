import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'common/themes/material.dart';
import 'models/app_model.dart';
import 'services/gauth.dart';
import 'services/gdrive.dart';
import 'widgets/dialogs/login.dart';
import 'widgets/navbars/bottom.dart';
import 'widgets/side_menu.dart';
import 'widgets/navbars/top.dart';
import 'widgets/tiles/file_menu.dart';
import 'widgets/tiles/folder_tile.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  int _selectedIndex = 0;
  bool _isInitialized = false;
  GDriveService? _googleDriveService;

  @override
  void initState() {
    super.initState();
    _initialize().then((_) {
      setState(() {
        _isInitialized = true;
      });
    });
  }

  Future<void> _initialize() async {
    AppModel model = context.read<AppModel>();
    GAuthService gauth = GAuthService(context: context);

    model.authClient = await gauth.getAuthClient();
    model.accounts = await GAuthService.listSavedCredentials();
    if (model.accounts == null || model.accounts!.isEmpty) {
      showLoginDialog(context);
    }
    model.selectedClientEmail =
        model.selectedClientEmail ?? model.accounts?.first;

    if (model.authClient != null) {
      _googleDriveService = GDriveService(
        context: context,
        authClient: model.authClient!,
      );
      await _loadFilesList();
    }
  }

  Future<void> _loadFilesList({
    String? folderId,
    bool sharedWithMe = false,
    bool trashed = false,
  }) async {
    if (_googleDriveService != null) {
      if (folderId != null) {
        context.read<AppModel>().navigateToFolder(folderId);
      }
      await _googleDriveService!.listFiles(
        folderId: folderId ?? context.read<AppModel>().currentFolderId,
        sharedWithMe: sharedWithMe,
        trashed: trashed,
      );
    }
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String filePath = result.files.single.path ?? '';
      if (filePath.isNotEmpty) {
        await _googleDriveService?.uploadFile(filePath);
        await _loadFilesList();
      }
    }
  }

  Future<void> _createFolder() async {
    TextEditingController folderController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create Folder"),
          content: TextField(
            controller: folderController,
            decoration: const InputDecoration(hintText: "Enter folder name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (folderController.text.isNotEmpty) {
                  await _googleDriveService?.createFolder(
                    folderController.text,
                  );
                  await _loadFilesList();
                  Navigator.pop(context);
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          theme: lightTheme(lightDynamic),
          darkTheme: darkTheme(darkDynamic),
          themeMode: ThemeMode.system,
          home: SafeArea(
            child: Consumer<AppModel>(
              builder: (context, model, child) {
                return Scaffold(
                  drawer: const SideMenu(),
                  appBar: TopBarWidget(
                    screen: _selectedIndex == 0 ? 'Home' : 'Shared with me',
                  ),
                  body:
                      model.files == null || model.files!.isEmpty
                          ? const Center(child: Text('No files available'))
                          : ListView.builder(
                            itemCount: model.files!.length,
                            itemBuilder: (context, index) {
                              final file = model.files![index];
                              return GestureDetector(
                                onTap:
                                    () => openFile(
                                      context,
                                      file,
                                      _googleDriveService!,
                                    ),
                                child:
                                    file!.mimeType ==
                                            'application/vnd.google-apps.folder'
                                        ? folderTile(
                                          context: context,
                                          file: file,
                                          loadFilesList: _loadFilesList,
                                          googleDriveService:
                                              _googleDriveService!,
                                        )
                                        : fileTile(
                                          context: context,
                                          file: file,
                                          googleDriveService:
                                              _googleDriveService!,
                                        ),
                              );
                            },
                          ),
                  bottomNavigationBar: BottomBarWidget(
                    selectedIndex: _selectedIndex,
                    onItemTapped: _onItemTapped,
                  ),
                  floatingActionButton: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        onPressed: _createFolder,
                        tooltip: 'Create Folder',
                        child: const Icon(Icons.create_new_folder),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: _uploadFile,
                        tooltip: 'Upload File',
                        child: const Icon(Icons.upload_file),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
