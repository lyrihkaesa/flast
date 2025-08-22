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
}) async {
  // Print flast version
  print('flast v$packageVersion');

  await _checkShell();

  // Interaktif fallback jika argumen tidak diberikan
  final interactive = projectName == null;
  final name = projectName ?? _askProjectName();
  final organization = org ?? _askOrg();
  final platforms = platformsCsv != null ? platformsCsv.split(',').map((e) => e.trim()).toList() : _askPlatforms();
  final androidLanguage = androidLang ?? _askAndroidLang();
  final iosLanguage = iosLang ?? _askIosLang();

  final allowOverwrite = await confirmOverwrite(name, force: force);
  if (!allowOverwrite) {
    print('❌ Project creation cancelled.');
    exit(0);
  }

  final shell = Shell();
  final flutterCmd = 'flutter';

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

  await shell.run(
    '$flutterCmd create --org $organization --platforms ${platforms.join(",")} '
    '--android-language $androidLanguage --ios-language $iosLanguage .',
  );

  await runPostSetup(shell: shell, interactive: interactive);

  _printNextSteps(name);
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

void _printNextSteps(String projectName) {
  print('\n🎉 Project $projectName created successfully!');
  logStep('cd $projectName');
  logStep('mason get');
  logStep('dart run build_runner build --delete-conflicting-outputs');
  logStep('flutter run');
  print('========================================================= \n');
}
