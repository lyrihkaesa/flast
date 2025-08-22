import 'dart:io';

import 'logger.dart';

Future<void> safeDelete(String path) async {
  final dir = Directory(path);
  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
}

Future<void> runCopy(String sourcePath, String destinationPath) async {
  final sourceFile = File(sourcePath);
  if (await sourceFile.exists()) {
    await sourceFile.copy(destinationPath);
    printBoxMessage('♥ Copied $sourcePath to $destinationPath');
  } else {
    printBoxMessage('○ Source file not found: $sourcePath');
  }
}
