import 'dart:convert';
import 'dart:io';
import 'package:process_run/shell.dart';

Future<void> installFlutterFromFvmrc(Shell shell) async {
  final fvmrcFile = File('.fvmrc');
  if (await fvmrcFile.exists()) {
    final content = await fvmrcFile.readAsString();
    try {
      final decoded = jsonDecode(content);
      final flutterVersion = decoded['flutter'];
      if (flutterVersion != null) {
        print('🚀 Installing Flutter version "$flutterVersion" from .fvmrc via FVM...');
        await shell.run('fvm install $flutterVersion --setup');
        print('🐣 Flutter "$flutterVersion" installed successfully!');
        await shell.run('fvm use $flutterVersion');
      } else {
        print('⚠️  .fvmrc does not contain "flutter" key.');
      }
    } catch (e) {
      print('⚠️  Failed to parse .fvmrc: $e');
    }
  } else {
    print('⚠️  No .fvmrc found. Skipping FVM install.');
  }
}
