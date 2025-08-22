import 'dart:io';
import 'package:archive/archive_io.dart';
import '../utils/logger.dart'; // Untuk printBoxMessage

/// Clone starter kit dari GitHub dengan caching ZIP
/// [repoUrl] = optional custom repo
/// [tag] = optional tag atau branch
/// [forceDownload] = jika true, download ulang meskipun cache ada
Future<void> cloneStarterKitZipCached(
  String projectName, {
  String? repoUrl,
  String? tag,
  bool forceDownload = false,
}) async {
  // Default repo
  final defaultRepo = 'https://github.com/lyrihkaesa/flutter_starter_kit';
  final repo = repoUrl ?? defaultRepo;

  // Tentukan cache directory
  final homeDir = Platform.isWindows ? Platform.environment['USERPROFILE'] : Platform.environment['HOME'];
  final cacheDir = Directory('${homeDir ?? '.'}/.flast_cache');
  if (!cacheDir.existsSync()) cacheDir.createSync(recursive: true);

// Gunakan sanitizeTag
  final formattedTag = sanitizeTag(tag);

// Tentukan nama ZIP sesuai repo/tag
  String zipFileName;
  if (repoUrl == null || repoUrl == defaultRepo) {
    zipFileName = formattedTag != 'main' ? 'kit_${formattedTag.replaceAll('/', '_')}.zip' : 'kit_main.zip';
  } else {
    final uri = Uri.parse(repo);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    String repoPart = 'custom_repo';
    if (segments.length >= 2) {
      repoPart = '${segments[0]}_${segments[1].replaceAll('.git', '')}';
    }
    zipFileName =
        formattedTag != 'main' ? '${repoPart}_${formattedTag.replaceAll('/', '_')}.zip' : '${repoPart}_main.zip';
  }

  final zipFile = File('${cacheDir.path}/$zipFileName');

  // Tentukan URL download
  final downloadUrl =
      formattedTag != 'main' ? '$repo/archive/refs/tags/$formattedTag.zip' : '$repo/archive/refs/heads/main.zip';

  // Download jika belum ada atau forceDownload = true
  if (!zipFile.existsSync() || forceDownload) {
    if (forceDownload && zipFile.existsSync()) {
      printBoxMessage('→ Force download enabled, deleting cached file:\n→ ${zipFile.path}');
      zipFile.deleteSync();
    }

    printBoxMessage('↓ Downloading starter kit...\nRepo: $repo\nVersion: ${tag ?? 'main'}\nPath: ${zipFile.path}');
    final result = await Process.run('curl', ['-L', downloadUrl, '-o', zipFile.path]);
    if (result.exitCode != 0) {
      printBoxMessage('○ Failed to download starter kit: \n→ ${result.stderr}');
      exit(1);
    }
    printBoxMessage('→ Download completed: \n→ ${zipFile.path}');
  } else {
    printBoxMessage('→ Using cached starter kit: \n→ ${zipFile.path}');
  }

  // Cek ukuran file ZIP minimal (GitHub 404 biasanya <10KB)
  if (zipFile.lengthSync() < 10 * 1024) {
    printBoxMessage('○ Warning: download kemungkinan gagal, ZIP terlalu kecil.');
    zipFile.deleteSync();
    exit(1);
  }

  // Ekstraksi
  printBoxMessage('→ Extracting starter kit to ./$projectName ...');

  // Cek apakah ZIP valid
  final bytes = zipFile.readAsBytesSync();
  Archive? archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
    if (archive.isEmpty) {
      printBoxMessage('○ Warning: ZIP archive kosong, download gagal.');
      zipFile.deleteSync();
      exit(1);
    }
  } catch (e) {
    printBoxMessage('○ Warning: ZIP corrupt, download gagal.');
    zipFile.deleteSync();
    exit(1);
  }

  // Root folder di dalam ZIP (GitHub menaruh semua di folder <repo>-<branch/tag>)
  final rootFolder = archive.first.name.split('/').first;

  for (int i = 0; i < archive.length; i++) {
    final file = archive[i];

    // Hilangkan folder root GitHub
    final relativePath = file.name.startsWith(rootFolder) ? file.name.substring(rootFolder.length + 1) : file.name;
    if (relativePath.isEmpty) continue;

    final outPath = '$projectName/$relativePath';
    if (file.isFile) {
      final outFile = File(outPath);
      outFile.createSync(recursive: true);
      outFile.writeAsBytesSync(file.content as List<int>);
    } else {
      Directory(outPath).createSync(recursive: true);
    }

    // Progress sederhana
    stdout.write('\r    $outPath\n  → Extracting: ${i + 1}/${archive.length} files...');
  }

  stdout.writeln('');
  printBoxMessage('→ Extraction complete!');

  // Pindah ke project directory
  Directory.current = projectName;
  print('  ♥ Starter kit ready at: \n  → ${Directory.current.path}');
}

/// Pastikan tag valid untuk GitHub
String sanitizeTag(String? inputTag) {
  if (inputTag == null || inputTag.isEmpty || inputTag == 'main') return 'main';

  // Tambahkan prefix 'v' jika belum ada
  String tagWithV = inputTag.startsWith('v') ? inputTag : 'v$inputTag';

  // Validasi format sederhana: vX.Y.Z (X,Y,Z angka)
  final regex = RegExp(r'^v\d+\.\d+\.\d+$');
  if (!regex.hasMatch(tagWithV)) {
    printBoxMessage('○ Tag "$inputTag" tidak valid.\n○ Gunakan format X.Y.Z (misal 0.0.1)');
    exit(1);
  }

  return tagWithV;
}
