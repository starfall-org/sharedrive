import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_model.dart';
import '../../services/gauth.dart';

void checkAndShowLoginDialog(BuildContext context) {
  final appModel = context.read<AppModel>();

  final clientEmail = appModel.selectedClientEmail;

  if (clientEmail!.isEmpty) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appModel.selectedClientEmail!.isEmpty) {
        showLoginDialog(context);
      }
    });
  }
}

void showLoginDialog(BuildContext context) {
  TextEditingController credController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Đăng Nhập'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: TextField(
                  controller: credController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Nhập hoặc chọn file JSON',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['json'],
                    );

                    if (result != null) {
                      final file = File(result.files.single.path!);
                      final content = await file.readAsString();

                      if (_isValidJson(content)) {
                        credController.text = content;
                      } else {
                        _showErrorDialog(
                          context,
                          'File JSON không hợp lệ hoặc thiếu khóa "client_email".',
                        );
                      }
                    }
                  } catch (e) {
                    _showErrorDialog(
                      context,
                      'Lỗi khi đọc file: ${e.toString()}',
                    );
                  }
                },
                child: Text('Chọn file JSON'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_isValidJson(credController.text)) {
                Navigator.of(context).pop();
                try {
                  GAuthService.saveCredentials(credController.text);
                  var credJson = jsonDecode(credController.text);
                  var clientEmail = credJson['client_email'];
                  context.read<AppModel>().updateClientEmail(
                    clientEmail,
                  ); // Notify listeners
                } catch (e) {
                  _showErrorDialog(context, e.toString());
                }
              } else {
                _showErrorDialog(
                  context,
                  'The JSON file is not valid or does not contain "client_email".',
                );
              }
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  ).then((_) {
    credController.dispose();
  });
}

bool _isValidJson(String content) {
  try {
    final data = jsonDecode(content);
    return data is Map<String, dynamic> && data.containsKey('client_email');
  } catch (e) {
    return false;
  }
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
