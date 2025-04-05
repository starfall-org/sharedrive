import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/credentials.dart';

void showLoginDialog(BuildContext context, Function(String) login) {
  TextEditingController credController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Login'),
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
                    hintText: 'Enter or select JSON file',
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
                          'Invalid JSON file or missing "client_email" key.',
                        );
                      }
                    }
                  } catch (e) {
                    _showErrorDialog(
                      context,
                      'Error reading file: ${e.toString()}',
                    );
                  }
                },
                child: Text('Select JSON file'),
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
                  Credentials.save(credController.text);
                  Map creds = jsonDecode(credController.text);
                  login(creds['client_email']);
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
        title: Text('Error'),
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
