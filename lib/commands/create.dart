import 'dart:io';
import 'package:interact/interact.dart';
import 'package:process_run/shell.dart';

import '../utils/file_ops.dart';
import '../utils/logger.dart';
import '../utils/project_utils.dart';
import 'install.dart';
import 'post_setup.dart';

/// Entry point untuk perintah `flast create`
Future<void> createProject({bool force = false}) async {
  _checkWindowsShell();

  // === Step 1: Tanya informasi project ===
  final projectName = _askProjectName();
  final allowOverwrite = await confirmOverwrite(projectName, force: force);
  if (!allowOverwrite) {
    print('❌ Project creation cancelled.');
    exit(0);
  }

  final org = _askOrg();
  final platforms = _askPlatforms();
  final androidLang = _askAndroidLang();
  final iosLang = _askIosLang();
  final useFvm = _askUseFvm();

  // === Step 2: Setup project ===
  final shell = Shell();
  final flutterCmd = useFvm ? 'fvm flutter' : 'flutter';

  await _cloneStarterKit(shell, projectName);
  await _updatePubspecName(projectName);

  await safeDelete('.git');
  await shell.run('git init');

  if (File('.env.example').existsSync()) {
    await runCopy('.env.example', '.env');
  }

  // Bersihkan platform lama dari starter kit
  for (var platform in ['android', 'ios', 'web', 'windows', 'linux', 'macos']) {
    await safeDelete(platform);
  }

  if (useFvm) {
    await installFlutterFromFvmrc(shell);
  }

  // Buat ulang project dengan konfigurasi user
  await shell.run(
    '$flutterCmd create --org $org --platforms ${platforms.join(",")} '
    '--android-language $androidLang --ios-language $iosLang .',
  );

  // === Step 3: Post setup ===
  await runPostSetup(shell: shell, useFvm: useFvm);

  // === Step 4: Print next steps ===
  _printNextSteps(projectName, useFvm);
}

//
// ===== HELPER FUNCTIONS =====
//

void _checkWindowsShell() {
  if (Platform.isWindows) {
    final shellEnv = Platform.environment['PSModulePath'];
    final isPowerShell = shellEnv != null;

    if (!isPowerShell) {
      print('⚠️  Please run this command in PowerShell to avoid path issues.');
      print('Example: powershell -Command "flast create"');
      exit(1);
    } else {
      print('✅ Detected PowerShell on Windows.');
    }
  }
}

String _askProjectName() {
  return Input(
    prompt: 'What is your project name?',
    defaultValue: 'my_app',
  ).interact();
}

String _askOrg() {
  return Input(
    prompt: 'What is your organization?',
    defaultValue: 'com.example',
  ).interact();
}

List<String> _askPlatforms() {
  final platformsSelection = MultiSelect(
    prompt: 'Choose platforms',
    options: ['android', 'ios', 'web', 'windows', 'linux', 'macos'],
    defaults: [true, true, true, false, false, false],
  ).interact();

  return [
    'android',
    'ios',
    'web',
    'windows',
    'linux',
    'macos',
  ].asMap().entries.where((e) => platformsSelection.contains(e.key)).map((e) => e.value).toList();
}

String _askAndroidLang() {
  final index = Select(
    prompt: 'Choose Android language',
    options: ['kotlin', 'java'],
    initialIndex: 0,
  ).interact();
  return ['kotlin', 'java'][index];
}

String _askIosLang() {
  final index = Select(
    prompt: 'Choose iOS language',
    options: ['swift', 'objective-c'],
    initialIndex: 0,
  ).interact();
  return ['swift', 'objective-c'][index];
}

bool _askUseFvm() {
  return Confirm(
    prompt: 'Do you want to use FVM?',
    defaultValue: false,
  ).interact();
}

Future<void> _cloneStarterKit(Shell shell, String projectName) async {
  await shell.run(
    'git clone https://github.com/lyrihkaesa/flutter_starter_kit.git $projectName',
  );
  Directory.current = projectName;
}

Future<void> _updatePubspecName(String projectName) async {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) return;

  final lines = pubspecFile.readAsLinesSync();
  final updatedLines = lines.map((line) {
    if (line.trim().startsWith('name:')) {
      return 'name: $projectName';
    }
    return line;
  }).toList();

  pubspecFile.writeAsStringSync(updatedLines.join('\n'));
  print('✅ Pubspec.yaml updated successfully!');
}

void _printNextSteps(String projectName, bool useFvm) {
  print('\n🎉 Project $projectName created successfully!');
  logStep('Next steps:');
  logStep('cd $projectName');
  logStep('mason get');
  logStep('dart run build_runner build --delete-conflicting-outputs');
  if (useFvm) {
    logStep('fvm use');
    logStep('fvm flutter run');
  } else {
    logStep('flutter run');
  }
  print('========================================================= \n');
}
