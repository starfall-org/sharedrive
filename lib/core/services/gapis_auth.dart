import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';

class GapisAuth {
  static Future<AuthClient> getAuthClient() async {
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
      jsonDecode(
        await rootBundle.loadString('assets/collection-service-account.json'),
      ),
    );

    final scopes = [
      'https://www.googleapis.com/auth/spreadsheets',
      'https://www.googleapis.com/auth/drive',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/gmail.send',
    ];

    final client = await clientViaServiceAccount(
      serviceAccountCredentials,
      scopes,
    );

    return client;
  }
}
