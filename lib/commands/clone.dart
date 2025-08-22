import 'dart:io';
import 'package:archive/archive_io.dart';
import '../utils/logger.dart'; // Untuk printBoxMessage

Future<void> cloneStarterKitZipCached(String projectName) async {
  // Tentukan home & cache directory
  final homeDir = Platform.isWindows ? Platform.environment['USERPROFILE'] : Platform.environment['HOME'];
  final cacheDir = Directory('${homeDir ?? '.'}/.flast_cache');
  if (!cacheDir.existsSync()) cacheDir.createSync(recursive: true);

  final zipFile = File('${cacheDir.path}/main.zip');

  // Download jika belum ada
  if (!zipFile.existsSync()) {
    printBoxMessage('↓ Downloading starter kit...\nPath: ${zipFile.path}');
    final result = await Process.run('curl',
        ['-L', 'https://github.com/lyrihkaesa/flutter_starter_kit/archive/refs/heads/main.zip', '-o', zipFile.path]);

    if (result.exitCode != 0) {
      printBoxMessage('○ Failed to download starter kit: \n→ ${result.stderr}');
      exit(1);
    }
    printBoxMessage('→ Download completed: \n→ ${zipFile.path}');
  } else {
    printBoxMessage('→ Using cached starter kit: \n→ ${zipFile.path}');
  }

  // Ekstraksi
  printBoxMessage('→ Extracting starter kit to ./$projectName ...');

  final bytes = zipFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  if (archive.isEmpty) {
    printBoxMessage('○ ZIP archive is empty!');
    exit(1);
  }

  // Root folder di dalam ZIP (biasanya "flutter_starter_kit-main")
  final rootFolder = archive.first.name.split('/').first;

  for (int i = 0; i < archive.length; i++) {
    final file = archive[i];
    // Hilangkan folder root GitHub
    final relativePath = file.name.startsWith(rootFolder) ? file.name.substring(rootFolder.length + 1) : file.name;

    if (relativePath.isEmpty) continue; // skip root folder

    final outPath = '$projectName/$relativePath';

    if (file.isFile) {
      final outFile = File(outPath);
      outFile.createSync(recursive: true);
      outFile.writeAsBytesSync(file.content as List<int>);
    } else {
      Directory(outPath).createSync(recursive: true);
    }

    // Progress
    stdout.write('\r    $outPath\n  → Extracting: ${i + 1}/${archive.length} files...');
  }
  stdout.writeln('');
  printBoxMessage('→ Extraction complete!');

  // Pindah ke project directory
  Directory.current = projectName;
  print('  ♥ Starter kit ready at: \n  → ${Directory.current.path}');
}
