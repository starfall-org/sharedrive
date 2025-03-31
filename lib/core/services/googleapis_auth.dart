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

    if (clientEmail == null || clientEmail.isEmpty) {
      throw Exception("File JSON không hợp lệ: Thiếu `client_email`.");
    }

    final dir = await getApplicationDocumentsDirectory();
    final credentialsDir = Directory('${dir.path}/credentials');

    if (!await credentialsDir.exists()) {
      await credentialsDir.create(recursive: true);
    }

    final filePath = '${credentialsDir.path}/$clientEmail.json';
    final file = File(filePath);

    if (await file.exists()) {
      throw Exception("Credentials đã tồn tại cho tài khoản: $clientEmail.");
    }

    await file.writeAsString(credStr);
  }

  static Future<ServiceAccountCredentials?> loadCredentials() async {
    SelectedCredentials selectedCredentials = SelectedCredentials();
    String? clientEmail = selectedCredentials.clientEmail;

    if (clientEmail == null) {
      var allCredentials = await listCredentials();
      if (allCredentials.isEmpty) {
        return null;
      }
      clientEmail = allCredentials.first;
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/credentials/$clientEmail.json';
    final file = File(filePath);

    if (!await file.exists()) {
      return null;
    }

    try {
      final jsonStr = await file.readAsString();
      final data = jsonDecode(jsonStr);
      return ServiceAccountCredentials.fromJson(data);
    } catch (e) {
      return null;
    }
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

    return files
        .where((f) => f is File && f.path.endsWith('.json'))
        .map((f) => f.uri.pathSegments.last.replaceAll('.json', ''))
        .toList();
  }

  static Future<AuthClient?> getServiceAccountClient() async {
    final credentials = await loadCredentials();
    if (credentials == null) return null;
    return await clientViaServiceAccount(credentials, [_scopes]);
  }
}
