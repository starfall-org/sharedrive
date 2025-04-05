import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:provider/provider.dart';

import 'common/themes/material.dart';
import 'data/credentials.dart';
import 'models/app_model.dart';
import 'models/file_model.dart';
import 'services/gauth.dart';
import 'services/gdrive.dart';
import 'widgets/actions/float_button.dart';
import 'widgets/dialogs/login.dart';
import 'widgets/file_list.dart';
import 'widgets/navbars/bottom.dart';
import 'widgets/open_file.dart';
import 'widgets/side_menu.dart';
import 'widgets/navbars/top.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  int _selectedIndex = 0;
  bool _isInitialized = false;
  late final GDrive gds;
  List<FileModel> files = [];

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
    List credList = await Credentials.list();
    String? selectedClientEmail = await Credentials.getSelected();
    if (credList.isEmpty) {
      showLoginDialog(context, _login);
    }
    if (selectedClientEmail == null) {
      Credentials.setSelected(credList.first['client_email']);
    }
    selectedClientEmail = await Credentials.getSelected();
    _login(selectedClientEmail!);
  }

  Future<void> _login(String clientEmail) async {
    AuthClient? authClient = await gauthClient(clientEmail);
    gds = GDrive.instance;
    gds.init(authClient!);
  }

  Future<void> _loadFilesList({
    String? folderId,
    bool sharedWithMe = false,
    bool trashed = false,
  }) async {
    if (folderId != null) {
      context.read<AppModel>().navigateToFolder(folderId);
    }
    files = await gds.ls(
      folderId: folderId ?? context.read<AppModel>().currentFolderId,
      sharedWithMe: sharedWithMe,
      trashed: trashed,
    );
  }

  void _onOpen(FileModel fileModel) {
    if (fileModel.file.mimeType == 'application/vnd.google-apps.folder') {
      _loadFilesList(folderId: fileModel.file.id);
    } else {
      OpenFile(context: context, fileModel: fileModel).open();
    }
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
                  drawer: SideMenu(login: _login),
                  appBar: TopBarWidget(
                    screen: _selectedIndex == 0 ? 'Home' : 'Shared with me',
                  ),
                  body: FileListWidget(
                    fileModels: files,
                    gds: gds,
                    open: _onOpen,
                  ),
                  bottomNavigationBar: BottomBarWidget(
                    selectedIndex: _selectedIndex,
                    onItemTapped: _onItemTapped,
                  ),
                  floatingActionButton: FloatButtons(
                    gds: gds,
                    onSuccess: () {
                      _loadFilesList();
                    },
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
