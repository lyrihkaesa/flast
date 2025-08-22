import 'dart:io';

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
    print('✅ Copied $sourcePath to $destinationPath');
  } else {
    print('⚠️ Source file not found: $sourcePath');
  }
}
