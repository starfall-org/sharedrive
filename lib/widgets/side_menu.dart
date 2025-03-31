import 'package:flutter/material.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:mediaplus/core/providers/gauth_settings.dart';
import 'package:mediaplus/core/services/googleapis_auth.dart';

class SideMenuWidget extends StatefulWidget {
  const SideMenuWidget({super.key});

  @override
  State<SideMenuWidget> createState() => SideMenuState();
}

class SideMenuState extends State<SideMenuWidget> {
  late Future<AuthClient> authClient;
  late GAuthSettings settings;

  @override
  void initState() {
    super.initState();
    settings = GAuthSettings();
    authClient = settings.selectedClient ?? GapisAuth.getUserAuthClient();
  }

  void _userAccountAuth() {
    authClient = GapisAuth.getUserAuthClient();
    settings.set(authClient);
  }

  void _serviceAccountAuth() {
    authClient = GapisAuth.getServiceAccountClient();
    settings.set(authClient);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            key: UniqueKey(),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Text(
              "Menu",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(title: Text('Đăng Nhập'), onTap: _userAccountAuth),
          ListTile(title: Text('Service Account'), onTap: _serviceAccountAuth),
        ],
      ),
    );
  }
}
