import 'package:flutter/material.dart';
import 'package:manydrive/app/data/credentials.dart';
import 'package:manydrive/app/widgets/dialogs/about.dart';
import 'package:manydrive/app/widgets/dialogs/login.dart';

class SideMenu extends StatefulWidget {
  final Function(String) login;
  const SideMenu({super.key, required this.login});
  @override
  SideMenuState createState() => SideMenuState();
}

class SideMenuState extends State<SideMenu> {
  String? selectedClientEmail;
  List<Map> accountsData = [];
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
      accountsData = credList.cast<Map>();
      accounts =
          credList.map((cred) => cred['client_email'] as String).toList();
    });
  }

  // Helper function để trích xuất username từ email
  String _extractUsername(String email) {
    return email.split('@').first;
  }

  // Helper function để lấy project_id từ credential data
  String _getProjectId(String clientEmail) {
    final cred = accountsData.firstWhere(
      (cred) => cred['client_email'] == clientEmail,
      orElse: () => {},
    );
    return cred['project_id']?.toString() ?? 'Unknown Project';
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
              items: uniqueAccounts
                  .map(
                    (email) => DropdownMenuItem(
                      value: email,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _extractUsername(email),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _getProjectId(email),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  Credentials.setSelected(value!);
                  widget.login(value);
                });
              },
              dropdownColor: Colors.blue.shade800,
              style: const TextStyle(color: Colors.white),
              underline: Container(
                height: 2,
                color: Colors.white70,
              ),
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
