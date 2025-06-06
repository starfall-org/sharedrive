import 'package:flutter/material.dart';

import '../data/credentials.dart';
import '../widgets/dialogs/login.dart';
import '../widgets/dialogs/about.dart';

class SideMenu extends StatefulWidget {
  final Function(String) login;
  const SideMenu({super.key, required this.login});
  @override
  SideMenuState createState() => SideMenuState();
}

class SideMenuState extends State<SideMenu> {
  String? selectedClientEmail;
  List<String> accounts = [];
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    selectedClientEmail = await Credentials.getSelected();
    List credList = await Credentials.list();
    setState(() {
      accounts =
          credList.map((cred) => cred['client_email'] as String).toList();
    });
  }

  void _addAccount(String clientEmail) async {
    await Credentials.setSelected(clientEmail);
    await _init(); // Cập nhật danh sách tài khoản và trạng thái
    setState(() {
      selectedClientEmail = clientEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ensure accounts list has unique values
    final uniqueAccounts = accounts.toSet().toList();

    // Ensure selectedClientEmail is valid
    if (!uniqueAccounts.contains(selectedClientEmail)) {
      selectedClientEmail =
          uniqueAccounts.isNotEmpty ? uniqueAccounts.first : null;
    }

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Service Account"),
            accountEmail: DropdownButton<String>(
              value: selectedClientEmail,
              items:
                  uniqueAccounts
                      .map(
                        (email) =>
                            DropdownMenuItem(value: email, child: Text(email)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  Credentials.setSelected(value!);
                  widget.login(value);
                });
              },
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          ListTile(
            leading: Icon(Icons.account_tree),
            title: Text("Add Service Account"),
            onTap: () {
              showLoginDialog(context, (clientEmail) {
                _addAccount(clientEmail);
              });
            },
          ),

          ListTile(
            leading: Icon(Icons.info),
            title: Text("About"),
            onTap: () {
              showAbout(context);
            },
          ),
        ],
      ),
    );
  }
}
