import 'package:flutter/material.dart';
import 'package:driveplus/core/services/googleapis_auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:driveplus/common/popup_login.dart';
import 'package:driveplus/core/providers/credentials_provider.dart';
import 'package:driveplus/screens/trashed_screen.dart';

class SideMenu extends StatefulWidget {
  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  Future<AuthClient?>? _authClientFuture;
  final SelectedCredentials _selectedCredentials = SelectedCredentials();

  List<String> _accountsEmails = [];

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    _authClientFuture = GapisAuth.getServiceAccountClient();
    _accountsEmails = await GapisAuth.listCredentials();
    if (_selectedCredentials.clientEmail == null &&
        _accountsEmails.isNotEmpty) {
      _selectedCredentials.clientEmail = _accountsEmails.first;
    }

    setState(() {});
  }

  void _onAccountSelected(String? email) async {
    if (email == null) return;
    setState(() {
      _selectedCredentials.clientEmail = email;
    });
    _authClientFuture = GapisAuth.getServiceAccountClient();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("Service Account"),
            accountEmail: DropdownButton<String>(
              value: _selectedCredentials.clientEmail,
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
              popupLogin(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text("Trashed"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TrashedScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
