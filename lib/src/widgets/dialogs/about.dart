import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showAbout(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: AlertDialog(
          title: Text("About"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Links:"),
              ListTile(
                leading: Icon(Icons.discord),
                title: Text("Discord"),
                onTap: () => _launchURL('https://discord.gg/tRJKfHFx'),
              ),
              ListTile(
                leading: Icon(Icons.code),
                title: Text("GitHub"),
                onTap: () => _launchURL('https://github.com/starfall-org'),
              ),
              ListTile(
                leading: Icon(Icons.telegram),
                title: Text("Telegram"),
                onTap: () => _launchURL('https://contentdownload.t.me/'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Không thể mở URL $url';
  }
}
