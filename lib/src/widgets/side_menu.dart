import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';

import '../services/gauth.dart';
import '../widgets/dialogs/login.dart';
import '../settings/credentials.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});
  @override
  SideMenuState createState() => SideMenuState();
}

class SideMenuState extends State<SideMenu> {
  late CredentialsNotifier _credentialsSettings;
  late GAuthService _gauth;
  AuthClient? _authClient;
  List<String> _accountsEmails = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _credentialsSettings = CredentialsNotifier();
      _gauth = GAuthService(_credentialsSettings.clientEmail);
    });
    AuthClient? tempAuthClient = await _gauth.getServiceAccountClient();
    setState(() {
      _authClient = tempAuthClient;
    });
    _loadAccounts();
    if (_credentialsSettings.clientEmail == null &&
        _accountsEmails.isNotEmpty) {
      _credentialsSettings.clientEmail = _accountsEmails.first;
    }
  }

  void _loadAccounts() async {
    List<String> tempAccountsList = await GAuthService.savedCredentialsList();
    setState(() {
      _accountsEmails = tempAccountsList;
    });
  }

  void _onAccountSelected(String? email) async {
    if (email == null) return;
    setState(() {
      _credentialsSettings.clientEmail = email;
    });
    _authClient = await _gauth.getServiceAccountClient();

    setState(() {});
  }

  void _onLogin(String credStr) async {
    await GAuthService.saveCredentials(credStr);
    await _loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("Service Account"),
            accountEmail: DropdownButton<String>(
              value: _credentialsSettings.clientEmail,
              items:
                  _accountsEmails
                      .map(
                        (email) =>
                            DropdownMenuItem(value: email, child: Text(email)),
                      )
                      .toList(),
              onChanged: _onAccountSelected,
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: Colors.blueAccent,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Add Service Account"),
            onTap: () {
              popupLogin(context, _onLogin);
            },
          ),
        ],
      ),
    );
  }
}
