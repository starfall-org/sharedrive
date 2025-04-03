import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/dialogs/login.dart';
import '../models/app_model.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});
  @override
  SideMenuState createState() => SideMenuState();
}

class SideMenuState extends State<SideMenu> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Consumer<AppModel>(
            builder: (context, model, child) {
              final accounts = model.accounts ?? [];
              final selectedEmail = model.selectedClientEmail;

              return UserAccountsDrawerHeader(
                accountName: const Text("Service Account"),
                accountEmail: DropdownButton<String>(
                  value: selectedEmail,
                  items:
                      accounts
                          .map(
                            (email) => DropdownMenuItem(
                              value: email,
                              child: Text(email ?? 'Unknown'),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      model.selectedClientEmail = value;
                    });
                  },
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Add Service Account"),
            onTap: () {
              showLoginDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
