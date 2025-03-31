import 'dart:convert';
import 'dart:io';

import 'package:driveplus/common/popup_login.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:driveplus/core/services/googleapis_auth.dart';
import 'package:driveplus/core/providers/credentials_provider.dart';

class SideMenuWidget extends StatefulWidget {
  const SideMenuWidget({super.key});

  @override
  State<SideMenuWidget> createState() => SideMenuState();
}

class SideMenuState extends State<SideMenuWidget> {
  late Future<AuthClient> authClient;
  late SelectedCredentials creds;

  @override
  void initState() {
    super.initState();
    creds = SelectedCredentials();
    authClient = GapisAuth.getServiceAccountClient();
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
          ListTile(title: Text('Đăng Nhập'), onTap: () => popupLogin(context)),
        ],
      ),
    );
  }
}
