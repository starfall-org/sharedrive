import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/app_model.dart';

class GAuthService {
  final String _scopes = 'https://www.googleapis.com/auth/drive';
  BuildContext context;

  GAuthService({required this.context});

  Future<ServiceAccountCredentials?> loadCredentials(
    String? clientEmail,
  ) async {
    String filePath;
    if (clientEmail != null) {
      final dir = await getApplicationDocumentsDirectory();
      filePath = '${dir.path}/credentials/$clientEmail.json';
    } else {
      List credentialsList = await listSavedCredentials();
      if (credentialsList.isEmpty) {
        // Trả về null nếu không có credentials nào được lưu
        return null;
      }
      final dir = await getApplicationDocumentsDirectory();
      filePath = '${dir.path}/credentials/${credentialsList[0]}.json';
    }

    final file = File(filePath);
    if (!await file.exists()) {
      // Trả về null nếu file không tồn tại
      return null;
    }

    try {
      final jsonStr = await file.readAsString();
      final data = jsonDecode(jsonStr);
      return ServiceAccountCredentials.fromJson(data);
    } catch (e) {
      throw Exception("Không thể đọc credentials từ tệp: $filePath");
    }
  }

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

  static Future<String?> deleteCredentials(String clientEmail) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/credentials/$clientEmail.json');
    if (!await file.exists()) return null;
    await file.delete();
    return clientEmail;
  }

  static Future<List<String>> listSavedCredentials() async {
    final dir = await getApplicationDocumentsDirectory();
    final accountsDir = Directory('${dir.path}/credentials');

    if (!await accountsDir.exists()) return [];

    final files = await accountsDir.list().toList();

    return files
        .where((f) => f is File && f.path.endsWith('.json'))
        .map((f) => f.uri.pathSegments.last.replaceAll('.json', ''))
        .toList();
  }

  Future<AuthClient?> getAuthClient() async {
    String? clientEmail = context.read<AppModel>().selectedClientEmail;
    ServiceAccountCredentials? credentials = await loadCredentials(clientEmail);

    if (credentials == null) {
      return null;
    }

    return clientViaServiceAccount(credentials, [_scopes]);
  }
}
