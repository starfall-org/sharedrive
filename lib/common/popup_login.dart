import 'dart:convert';
import 'dart:io';
import 'package:driveplus/core/services/googleapis_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void popupLogin(BuildContext context) {
  TextEditingController credController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Đăng Nhập'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: credController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập hoặc chọn file JSON',
                border: OutlineInputBorder(),
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
                GapisAuth.saveCredentials(credController.text);
              } else {
                _showErrorDialog(
                  context,
                  'Nội dung không phải JSON hợp lệ hoặc thiếu khóa "client_email".',
                );
              }
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  ).then((_) {
    credController.dispose(); // Giải phóng bộ nhớ khi hộp thoại đóng
  });
}

/// Kiểm tra xem nội dung có phải là JSON hợp lệ và chứa khóa "client_email" không
bool _isValidJson(String content) {
  try {
    final data = jsonDecode(content);
    return data is Map<String, dynamic> && data.containsKey('client_email');
  } catch (e) {
    return false;
  }
}

/// Hiển thị hộp thoại lỗi
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
