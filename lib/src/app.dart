import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';

import 'common/themes/material.dart';
import 'models/app_model.dart';
import 'screens/main.dart';
import 'services/gauth.dart';
import 'widgets/dialogs/login.dart';
import 'widgets/navbars/bottom.dart';
import 'widgets/side_menu.dart';
import 'widgets/navbars/top.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    AppModel model = context.read<AppModel>();
    GAuthService gauth = GAuthService(model.selectedClientEmail);

    model.authClient = gauth.client;
    model.accounts = await GAuthService.listSavedCredentials();
    if (model.accounts!.isEmpty) {
      showLoginDialog(context);
    }
    model.selectedClientEmail =
        model.selectedClientEmail ?? model.accounts!.first;
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
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          theme: lightTheme(lightDynamic),
          darkTheme: darkTheme(darkDynamic),
          themeMode: ThemeMode.system,

          home: SafeArea(
            child: Scaffold(
              drawer: SideMenu(),
              appBar: TopBarWidget(
                screen: _selectedIndex == 0 ? "Files" : "Share with me",
              ),
              body: Center(
                child: MainScreen(isSharedWithMe: _selectedIndex == 1),
              ),

              bottomNavigationBar: BottomBarWidget(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
          ),
        );
      },
    );
  }
}
