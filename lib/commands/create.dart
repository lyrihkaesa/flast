import 'dart:convert';
import 'dart:io';
import 'package:interact/interact.dart';
import 'package:process_run/shell.dart';
import '../utils/file_ops.dart';
import '../utils/logger.dart';
import '../utils/project_utils.dart';
import '../version.dart';
import 'clone.dart';
import 'post_setup.dart';

Future<void> createProject({
  String? projectName,
  String? org,
  String? platformsCsv,
  String? androidLang,
  String? iosLang,
  bool force = false,
  bool useFvm = false,
  bool skipPubGet = false,
  String? kitVersion,
  String? kitRepo,
  bool forceDownload = false,
}) async {
  print(' ♥ flast v$packageVersion');

  await _checkShell();

  // Tentukan interaktivitas: jika projectName sudah diisi, skip semua prompt
  final interactive = projectName == null;

  final name = projectName ?? _askProjectName();

  final allowOverwrite = await confirmOverwrite(name, force: force);
  if (!allowOverwrite) {
    printBoxMessage('♦ Project creation cancelled.');
    exit(0);
  }

  // Pilihan proyek
  final organization = org ?? (interactive ? _askOrg() : 'com.example');
  final platforms = platformsCsv != null
      ? platformsCsv.split(',').map((e) => e.trim()).toList()
      : (interactive ? _askPlatforms() : ['android', 'ios', 'web']);
  final androidLanguage = androidLang ?? (interactive ? _askAndroidLang() : 'kotlin');
  final iosLanguage = iosLang ?? (interactive ? _askIosLang() : 'swift');

  final shell = Shell();

  // **Starter kit**
  String finalKitRepo = kitRepo ??
      (interactive
          ? Input(
              prompt: 'Enter starter kit repo URL (default: https://github.com/lyrihkaesa/flutter_starter_kit)',
              defaultValue: 'https://github.com/lyrihkaesa/flutter_starter_kit',
            ).interact()
          : null) ??
      'https://github.com/lyrihkaesa/flutter_starter_kit';

  String? finalKitVersion = kitVersion ??
      (interactive
          ? Input(
              prompt: 'Enter starter kit version/tag (leave empty for main)',
              defaultValue: 'main',
            ).interact()
          : null);

  bool finalForceDownload = forceDownload;
  if (interactive) {
    finalForceDownload = Confirm(
      prompt: 'Force download starter kit even if cached?',
      defaultValue: false,
    ).interact();
  }

  await cloneStarterKitZipCached(
    name,
    repoUrl: finalKitRepo,
    tag: finalKitVersion,
    forceDownload: finalForceDownload,
  );

  await _updatePubspecName(name);

  if (File('.env.example').existsSync()) {
    await runCopy('.env.example', '.env');
  }

  for (var platform in ['android', 'ios', 'web', 'windows', 'linux', 'macos']) {
    printBoxMessage('♦ Cleaning $platform...');
    await safeDelete(platform);
  }

  // FVM setup
  bool shouldUseFvm = useFvm;
  if (interactive && !useFvm) {
    shouldUseFvm = Confirm(
      prompt: 'Do you want to use FVM (Flutter version management)?',
      defaultValue: false,
    ).interact();
  }

  if (shouldUseFvm) {
    await _setupFvmIfNeeded(shell, useFvm: true);
  }

  // Tentukan skipPubGet interaktif
  if (!skipPubGet && interactive) {
    skipPubGet = Confirm(
      prompt: 'Do you want to skip "pub get"?',
      defaultValue: false,
    ).interact();
  }

  // Flag untuk flutter create
  final noPubFlag = skipPubGet ? ' --no-pub ' : ' ';

  // flutter create
  final flutterCmd = shouldUseFvm ? 'fvm flutter' : 'flutter';
  await shell.run(
    '$flutterCmd create$noPubFlag--org $organization --platforms ${platforms.join(",")} '
    '--android-language $androidLanguage --ios-language $iosLanguage .',
  );

  final postSetupResult = await runPostSetup(
    shell: shell,
    interactive: interactive,
    useFvm: shouldUseFvm,
    skipPubGet: skipPubGet,
  );

  _printNextSteps(
    name,
    isUseFvm: shouldUseFvm,
    isRunMason: postSetupResult['isRunMason']!,
    isRunBuildRunner: postSetupResult['isRunBuildRunner']!,
    isSkipPubGet: skipPubGet,
  );
}

Future<void> _checkShell() async {
  if (!Platform.isWindows) return;
  bool isBat = false;
  try {
    final result = await Process.run('where', ['flast']);
    if (result.exitCode == 0) {
      final lines = (result.stdout as String).split('\n');
      isBat = lines.any((line) => line.trim().toLowerCase().endsWith('.bat'));
    }
  } catch (_) {
    // Ignore errors
  }

  if (isBat) {
    printBoxMessage(
      '● flast is called via .bat. Interactive prompts may freeze in Git Bash.\n'
      '● Please use PowerShell or CMD for a smooth experience.',
      minWidth: 80,
    );
  } else {
    printBoxMessage('♦ Detected compatible shell on Windows.');
  }
}

// ===== Interactive helpers =====
String _askProjectName() => Input(prompt: 'What is your project name?', defaultValue: 'my_app').interact();
String _askOrg() => Input(prompt: 'Organization?', defaultValue: 'com.example').interact();

List<String> _askPlatforms() {
  final selected = MultiSelect(
    prompt: 'Choose platforms',
    options: ['android', 'ios', 'web', 'windows', 'linux', 'macos'],
    defaults: [true, true, true, false, false, false],
  ).interact();

  return ['android', 'ios', 'web', 'windows', 'linux', 'macos']
      .asMap()
      .entries
      .where((e) => selected.contains(e.key))
      .map((e) => e.value)
      .toList();
}

String _askAndroidLang() {
  final idx = Select(prompt: 'Choose Android language', options: ['kotlin', 'java']).interact();
  return ['kotlin', 'java'][idx];
}

String _askIosLang() {
  final idx = Select(prompt: 'Choose iOS language', options: ['swift', 'objective-c']).interact();
  return ['swift', 'objective-c'][idx];
}

Future<void> _updatePubspecName(String projectName) async {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) return;

  final lines = pubspecFile.readAsLinesSync();
  final updated = lines.map((l) => l.trim().startsWith('name:') ? 'name: $projectName' : l).toList();
  pubspecFile.writeAsStringSync(updated.join('\n'));
  printBoxMessage('♦ pubspec.yaml updated successfully!');
}

void _printNextSteps(
  String projectName, {
  bool isUseFvm = false,
  bool isRunMason = false,
  bool isRunBuildRunner = false,
  bool isSkipPubGet = false,
}) {
  int minWidth = 40;
  final fvmCmd = isUseFvm ? 'fvm ' : '';

  final buffer = StringBuffer();

  buffer.writeln('\$ cd $projectName');
  if (isSkipPubGet) {
    buffer.writeln('\$ ${fvmCmd}flutter pub get');
  }

  if (!isRunMason) {
    buffer.writeln('\$ mason get');
  }

  if (!isRunBuildRunner) {
    buffer.writeln('\$ ${fvmCmd}dart run build_runner build --delete-conflicting-outputs');
    minWidth = 66;
  }

  buffer.writeln('\$ ${fvmCmd}flutter run');

  printBoxMessage(
    buffer.toString(),
    header: '♣ Project my_app created successfully!',
    minWidth: minWidth,
    paddingLeft: 2,
    paddingRight: 0,
    marginTop: 1,
    marginBottom: 1,
  );
}

Future<void> _setupFvmIfNeeded(Shell shell, {required bool useFvm}) async {
  if (!useFvm) return;

  final fvmrcFile = File('.fvmrc');
  if (!await fvmrcFile.exists()) {
    printBoxMessage('○ No .fvmrc found. Skipping FVM setup.');
    return;
  }

  try {
    // Tampilkan daftar versi FVM yang ada sebelum install
    printBoxMessage('¶ Current FVM versions installed:');
    await shell.run('fvm list');

    // Baca versi Flutter dari .fvmrc
    final content = await fvmrcFile.readAsString();
    final decoded = jsonDecode(content);
    final flutterVersion = decoded['flutter'];
    if (flutterVersion == null) {
      printBoxMessage('○ .fvmrc does not contain "flutter" key.');
      return;
    }

    printBoxMessage('¶ Installing Flutter version "$flutterVersion" via FVM...');
    await shell.run('fvm install $flutterVersion --setup');

    // printBoxMessage('¶ Setting FVM global version to "$flutterVersion"...');
    // await shell.run('fvm global $flutterVersion');

    printBoxMessage('¶ Using FVM version "$flutterVersion" for this project...');
    await shell.run('fvm use $flutterVersion');

    // Tampilkan daftar versi FVM lagi setelah setting global
    printBoxMessage('¶ FVM versions installed');
    await shell.run('fvm list');

    printBoxMessage('¶ Flutter "$flutterVersion" is ready via FVM!');
  } catch (e) {
    printBoxMessage('○ Failed to setup FVM: $e');
  }
}
