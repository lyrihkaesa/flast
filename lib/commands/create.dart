import 'dart:convert';
import 'dart:io';
import 'package:interact/interact.dart';
import 'package:process_run/shell.dart';
import '../utils/file_ops.dart';
import '../utils/logger.dart';
import '../utils/project_utils.dart';
import '../version.dart';
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
}) async {
  print('flast v$packageVersion');

  await _checkShell();

  // Tentukan interaktivitas: jika projectName sudah diisi, skip semua prompt
  final interactive = projectName == null;

  // Pilihan proyek
  final name = projectName ?? _askProjectName();
  final organization = org ?? (interactive ? _askOrg() : 'com.example');
  final platforms = platformsCsv != null
      ? platformsCsv.split(',').map((e) => e.trim()).toList()
      : (interactive ? _askPlatforms() : ['android', 'ios', 'web']);
  final androidLanguage = androidLang ?? (interactive ? _askAndroidLang() : 'kotlin');
  final iosLanguage = iosLang ?? (interactive ? _askIosLang() : 'swift');

  final allowOverwrite = await confirmOverwrite(name, force: force);
  if (!allowOverwrite) {
    print('❌ Project creation cancelled.');
    exit(0);
  }

  final shell = Shell();

  // Clone starter kit
  await _cloneStarterKit(shell, name);
  await _updatePubspecName(name);

  await safeDelete('.git');
  await shell.run('git init');

  if (File('.env.example').existsSync()) {
    await runCopy('.env.example', '.env');
  }

  for (var platform in ['android', 'ios', 'web', 'windows', 'linux', 'macos']) {
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
    print('⚠️  flast is called via .bat. Interactive prompts may freeze in Git Bash.');
    print('   Please use PowerShell or CMD for a smooth experience.\n');
  } else {
    print('✅ Detected compatible shell on Windows.\n');
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

// ===== Internal helpers =====
Future<void> _cloneStarterKit(Shell shell, String projectName) async {
  await shell.run('git clone https://github.com/lyrihkaesa/flutter_starter_kit.git $projectName');
  Directory.current = projectName;
}

Future<void> _updatePubspecName(String projectName) async {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) return;

  final lines = pubspecFile.readAsLinesSync();
  final updated = lines.map((l) => l.trim().startsWith('name:') ? 'name: $projectName' : l).toList();
  pubspecFile.writeAsStringSync(updated.join('\n'));
  print('✅ Pubspec.yaml updated successfully!');
}

void _printNextSteps(
  String projectName, {
  bool isUseFvm = false,
  bool isRunMason = false,
  bool isRunBuildRunner = false,
  bool isSkipPubGet = false,
}) {
  final flutterCmd = isUseFvm ? 'fvm flutter' : 'flutter';

  print('\n==============================================================\n');
  print('  🎉  Project $projectName created successfully!\n');

  logStep('cd $projectName');

  // Pub get
  if (isSkipPubGet) {
    logStep('$flutterCmd pub get');
  }

  // Mason
  if (!isRunMason) {
    logStep('mason get');
  }

  // Build runner
  if (!isRunBuildRunner) {
    logStep('dart run build_runner build --delete-conflicting-outputs');
  }

  // Flutter run
  logStep('$flutterCmd run');

  print('\n==============================================================\n');
}

Future<void> _setupFvmIfNeeded(Shell shell, {required bool useFvm}) async {
  if (!useFvm) return;

  final fvmrcFile = File('.fvmrc');
  if (!await fvmrcFile.exists()) {
    print('⚠️  No .fvmrc found. Skipping FVM setup.');
    return;
  }

  try {
    // Tampilkan daftar versi FVM yang ada sebelum install
    print('\nℹ️  Current FVM versions installed:');
    await shell.run('fvm list');

    // Baca versi Flutter dari .fvmrc
    final content = await fvmrcFile.readAsString();
    final decoded = jsonDecode(content);
    final flutterVersion = decoded['flutter'];
    if (flutterVersion == null) {
      print('⚠️  .fvmrc does not contain "flutter" key.');
      return;
    }

    print('\n🚀  Installing Flutter version "$flutterVersion" via FVM...');
    await shell.run('fvm install $flutterVersion --setup');

    // print('⚠️  Setting FVM global version to "$flutterVersion"...');
    // await shell.run('fvm global $flutterVersion');

    print('🚀  Using FVM version "$flutterVersion" for this project...');
    await shell.run('fvm use $flutterVersion');

    // Tampilkan daftar versi FVM lagi setelah setting global
    print('\nℹ️  FVM versions installed');
    await shell.run('fvm list');

    print('\n✅  Flutter "$flutterVersion" is ready via FVM!');
  } catch (e) {
    print('⚠️  Failed to setup FVM: $e');
  }
}
