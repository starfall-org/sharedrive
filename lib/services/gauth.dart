import 'package:googleapis_auth/auth_io.dart';

import '../data/credentials.dart';

List<String> _scopes = ['https://www.googleapis.com/auth/drive'];

Future<AuthClient?> gauthClient(String clientEmail) async {
  Map? credentials = await Credentials.get(clientEmail);

  ServiceAccountCredentials serviceAccountCredentials =
      ServiceAccountCredentials.fromJson(credentials);

  if (credentials == null) {
    return null;
  }

  return clientViaServiceAccount(serviceAccountCredentials, _scopes);
}
