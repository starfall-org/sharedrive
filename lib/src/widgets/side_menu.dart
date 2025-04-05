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
    for (var cred in credList) {
      accounts.add(cred['client_email']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Service Account"),
            accountEmail: DropdownButton<String>(
              value: selectedClientEmail,
              items:
                  accounts
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
              showLoginDialog(context, widget.login);
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
