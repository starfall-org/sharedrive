import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:manydrive/app/common/themes/material.dart';
import 'package:manydrive/app/data/credentials.dart';
import 'package:manydrive/app/models/file_model.dart';
import 'package:manydrive/app/services/gauth.dart';
import 'package:manydrive/app/services/gdrive.dart';
import 'package:manydrive/app/widgets/actions/float_button.dart';
import 'package:manydrive/app/widgets/dialogs/login.dart';
import 'package:manydrive/app/widgets/file_list.dart';
import 'package:manydrive/app/widgets/navbars/bottom.dart';
import 'package:manydrive/app/widgets/navbars/top.dart';
import 'package:manydrive/app/widgets/open_file.dart';
import 'package:manydrive/app/widgets/side_menu.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  int _selectedIndex = 0;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isSuperDarkMode = false;
  late final GDrive gds;
  late final PageController _pageController;
  final GlobalKey<FileListWidgetState> _homeFileListKey = GlobalKey<FileListWidgetState>();
  final GlobalKey<FileListWidgetState> _sharedFileListKey = GlobalKey<FileListWidgetState>();

  @override
  void initState() {
    super.initState();
    gds = GDrive.instance;
    _pageController = PageController(initialPage: 0);
    _initialize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _login(String clientEmail) async {
    AuthClient? authClient = await gauthClient(clientEmail);
    await gds.login(authClient!);
  }

  Future<void> _initialize() async {
    List<Map> credList = await Credentials.list();
    String? selectedClientEmail = await Credentials.getSelected();
    if (credList.isEmpty) {
      showLoginDialog(context, _login);
      return;
    }
    if (selectedClientEmail == null) {
      selectedClientEmail = credList.first['client_email'];
      Credentials.setSelected(selectedClientEmail!);
    }
    await _login(selectedClientEmail);
    
    // Load dữ liệu ban đầu cho cả 2 tab sau khi login
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      gds.ls(tabKey: 'home');
      gds.ls(sharedWithMe: true, tabKey: 'shared');
    }
  }

  void _onOpen(FileModel fileModel, String tabKey, List<FileModel> allFiles) {
    if (fileModel.file.mimeType == 'application/vnd.google-apps.folder') {
      gds.ls(folderId: fileModel.file.id, tabKey: tabKey);
    } else {
      OpenFile(
        context: context,
        fileModel: fileModel,
        allFiles: allFiles,
      ).open();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  void _onThemeModeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void _toggleSuperDarkMode(bool value) {
    setState(() {
      _isSuperDarkMode = value;
    });
  }

  Future<bool> _onWillPop() async {
    // Kiểm tra pathHistory của tab hiện tại
    final currentTabKey = _selectedIndex == 0 ? 'home' : 'shared';
    final currentHistory = gds.getPathHistory(currentTabKey);
    
    // Nếu đang ở trong thư mục con, quay lại thư mục cha
    if (currentHistory.isNotEmpty) {
      gds.rollback(currentTabKey);
      return false; // Không thoát ứng dụng
    }
    // Nếu đang ở thư mục gốc, thoát ứng dụng
    SystemNavigator.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          theme: lightTheme(lightDynamic),
          darkTheme: darkTheme(darkDynamic, superDark: _isSuperDarkMode),
          themeMode: _themeMode,
          home: PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, Object? result) async {
              if (didPop) return;
              await _onWillPop();
            },
            child: StreamBuilder<List<FileModel>>(
              stream: gds.getFilesListStream(_selectedIndex == 0 ? 'home' : 'shared'),
              builder: (context, snapshot) {
                final currentTabKey = _selectedIndex == 0 ? 'home' : 'shared';
                final pathHistory = gds.getPathHistory(currentTabKey);
                final hasHistory = pathHistory.isNotEmpty;

                return Scaffold(
                  drawer: SideMenu(
                    login: _login,
                    themeMode: _themeMode,
                    onThemeModeChanged: _onThemeModeChanged,
                    isSuperDarkMode: _isSuperDarkMode,
                    onSuperDarkModeChanged: _toggleSuperDarkMode,
                  ),

                  appBar: TopBarWidget(
                    screen: _selectedIndex == 0 ? 'Home' : 'Shared with me',
                    onSortPressed: () {
                      if (_selectedIndex == 0) {
                        _homeFileListKey.currentState?.showSortMenu();
                      } else {
                        _sharedFileListKey.currentState?.showSortMenu();
                      }
                    },
                    onReloadPressed: () {
                      final currentTabKey = _selectedIndex == 0 ? 'home' : 'shared';
                      gds.refresh(currentTabKey);
                    },
                    onBackPressed: hasHistory
                        ? () => gds.rollback(currentTabKey)
                        : null,
                  ),

                  body: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    children: [
                      FileListWidget(
                        key: _homeFileListKey,
                        gds: gds,
                        open: (fileModel, allFiles) => _onOpen(fileModel, 'home', allFiles),
                        tabKey: 'home',
                        isSharedWithMe: false,
                      ),
                      FileListWidget(
                        key: _sharedFileListKey,
                        gds: gds,
                        open: (fileModel, allFiles) => _onOpen(fileModel, 'shared', allFiles),
                        tabKey: 'shared',
                        isSharedWithMe: true,
                      ),
                    ],
                  ),

                  bottomNavigationBar: BottomBarWidget(
                    selectedIndex: _selectedIndex,
                    onItemTapped: _onItemTapped,
                  ),

                  floatingActionButton: FloatButtons(
                    gds: gds,
                    tabKey: _selectedIndex == 0 ? 'home' : 'shared',
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
