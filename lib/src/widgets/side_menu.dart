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
              return UserAccountsDrawerHeader(
                accountName: Text("Service Account"),
                accountEmail: DropdownButton<String>(
                  value: model.selectedClientEmail,
                  items:
                      model.accounts!
                          .map(
                            (email) => DropdownMenuItem(
                              value: email,
                              child: Text(email!),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => {model.selectedClientEmail = value},
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Add Service Account"),
            onTap: () {
              popupLogin(context);
            },
          ),
        ],
      ),
    );
  }
}
