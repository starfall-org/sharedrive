import 'package:flutter/material.dart';

import '../../models/file_model.dart';

void showMetadataDialog(BuildContext context, FileModel file) async {
  var metadata = await file.metadata();
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Metadata'),
          content: Text(metadata.toString()),
        ),
  );
}
