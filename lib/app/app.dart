import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
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
  late final GDrive gds;

  @override
  void initState() {
    super.initState();
    gds = GDrive.instance;
    _initialize();
  }

  Future<void> _login(String clientEmail) async {
    AuthClient? authClient = await gauthClient(clientEmail);
    gds.login(authClient!);
  }

  Future<void> _initialize() async {
    List<Map> credList = await Credentials.list();
    String? selectedClientEmail = await Credentials.getSelected();
    if (credList.isEmpty) {
      showLoginDialog(context, _login);
    }
    if (selectedClientEmail == null) {
      selectedClientEmail = credList.first['client_email'];
      Credentials.setSelected(selectedClientEmail!);
    }
    _login(selectedClientEmail);
    gds.ls();
  }

  void _onOpen(FileModel fileModel) {
    if (fileModel.file.mimeType == 'application/vnd.google-apps.folder') {
      gds.ls(folderId: fileModel.file.id);
    } else {
      OpenFile(context: context, fileModel: fileModel).open();
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      if (index == 0) {
        gds.ls();
      } else {
        gds.ls(sharedWithMe: true);
      }
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          theme: lightTheme(lightDynamic),
          darkTheme: darkTheme(darkDynamic),
          themeMode: ThemeMode.system,
          home: SafeArea(
            child: Scaffold(
              drawer: SideMenu(login: _login),

              appBar: TopBarWidget(
                screen: _selectedIndex == 0 ? 'Home' : 'Shared with me',
              ),

              body: FileListWidget(gds: gds, open: _onOpen),

              bottomNavigationBar: BottomBarWidget(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),

              floatingActionButton: FloatButtons(gds: gds),
            ),
          ),
        );
      },
    );
  }
}
