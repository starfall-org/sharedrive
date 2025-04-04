import 'package:flutter/material.dart';

import '../../models/gdrive/file.dart';

void showMetadataDialog(BuildContext context, FileModel file) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Metadata'),
          content: const Text('Metadata'),
        ),
  );
}
