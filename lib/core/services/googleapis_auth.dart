import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:driveplus/core/providers/credentials_provider.dart';

class GapisAuth {
  static const String _scopes = 'https://www.googleapis.com/auth/drive';

  static Future<void> saveCredentials(String credStr) async {
    final credJson = jsonDecode(credStr);
    final clientEmail = credJson['client_email'];
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/credentials/$clientEmail.json');
    await file.writeAsString(credStr);
  }

  static Future<ServiceAccountCredentials> loadCredentials() async {
    SelectedCredentials selectedCredentials = SelectedCredentials();
    late String clientEmail;
    if (selectedCredentials.clientEmail == null) {
      var allCredentials = await listCredentials();
      clientEmail = allCredentials.first;
    } else {
      clientEmail = selectedCredentials.clientEmail!;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/credentials/$clientEmail.json');

    final jsonStr = await file.readAsString();
    final data = jsonDecode(jsonStr);
    return ServiceAccountCredentials.fromJson(data);
  }

  static Future<String?> deleteCredentials(String clientEmail) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/credentials/$clientEmail.json');
    if (!await file.exists()) return null;
    await file.delete();
    return clientEmail;
  }

  static Future<List<String>> listCredentials() async {
    final dir = await getApplicationDocumentsDirectory();
    final accountsDir = Directory('${dir.path}/credentials');
    if (!await accountsDir.exists()) return [];
    final files = await accountsDir.list().toList();
    return files.map((f) => f.path).toList();
  }

  static Future<AuthClient> getServiceAccountClient() async {
    final credentials = await loadCredentials();
    final client = await clientViaServiceAccount(credentials, [_scopes]);
    return client;
  }
}
