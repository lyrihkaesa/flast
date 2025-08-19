import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:interact/interact.dart';
import 'package:process_run/shell.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()..addCommand('create');
  final results = parser.parse(arguments);

  if (results.command?.name == 'create') {
    await createProject();
  } else {
    print('Usage: flast create');
  }
}

Future<void> createProject() async {
  if (Platform.isWindows) {
    // Cek apakah sedang di PowerShell
    final shellEnv = Platform.environment['PSModulePath'];
    final isPowerShell = shellEnv != null;

    if (!isPowerShell) {
      print('⚠️  Please run this command in PowerShell to avoid path issues.');
      print('Example:');
      print('powershell -Command "flast create"');
      exit(1);
    } else {
      print('✅ Detected PowerShell on Windows.');
    }
  }

  final projectName = Input(prompt: 'What is your project name?', defaultValue: 'my_app').interact();

  // Cek apakah project sudah ada
  await handleExistingProject(projectName);

  final shell = Shell();

  // Prompt data dari user
  final org = Input(prompt: 'What is your organization?', defaultValue: 'com.example').interact();

  final platformsSelection = MultiSelect(
    prompt: 'Choose platforms (use ↑/↓ to navigate, space to select, enter to confirm)',
    options: ['android', 'ios', 'web', 'windows', 'linux', 'macos'],
    defaults: [true, true, true, false, false, false],
  ).interact();

  final platforms = [
    'android',
    'ios',
    'web',
    'windows',
    'linux',
    'macos',
  ].asMap().entries.where((e) => platformsSelection.contains(e.key)).map((e) => e.value).toList();

  // Tanya apakah menggunakan FVM
  final useFvm = Confirm(prompt: 'Do you want to use FVM?', defaultValue: false).interact();

  final flutterCmd = useFvm ? 'fvm flutter' : 'flutter';

  // Pilih bahasa Android
  final androidLangIndex =
      Select(prompt: 'Choose Android language', options: ['kotlin', 'java'], initialIndex: 0).interact();
  final androidLang = ['kotlin', 'java'][androidLangIndex];

  // Pilih bahasa iOS
  final iosLangIndex =
      Select(prompt: 'Choose iOS language', options: ['swift', 'objective-c'], initialIndex: 0).interact();
  final iosLang = ['swift', 'objective-c'][iosLangIndex];

  // Clone starter kit
  await shell.run('git clone https://github.com/lyrihkaesa/flutter_starter_kit.git $projectName');

  // Masuk folder project
  Directory.current = projectName;

  // Ubah name di pubspec.yaml
  final pubspecFile = File('pubspec.yaml');
  if (pubspecFile.existsSync()) {
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

  // Hapus git lama dan init ulang
  await safeDelete('.git');
  await shell.run('git init');

  // Copy .env.example jika ada
  if (File('.env.example').existsSync()) {
    await runCopy('.env.example', '.env');
  }

  // Hapus semua platform lama
  for (var platform in ['android', 'ios', 'web', 'windows', 'linux', 'macos']) {
    await safeDelete(platform);
  }

  // Install Flutter versi yang diminta via FVM (jika dipilih)
  if (useFvm) {
    // await shell.run('fvm install $flutterVersion --setup');
    await installFlutterFromFvmrc(shell);
  }

  // Jalankan flutter create dengan bahasa yang dipilih
  await shell.run(
    '$flutterCmd create --org $org --platforms ${platforms.join(",")} '
    '--android-language $androidLang --ios-language $iosLang .',
  );

  await runPostSetup(shell: shell, useFvm: useFvm);

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
    print('⚠️  Source file not found: $sourcePath');
  }
}

void logStep(String message, {int indent = 2}) {
  final spaces = ' ' * indent;
  print('$spaces$message');
}

Future<void> runPostSetup({required Shell shell, bool useFvm = false}) async {
  // Tanya user apakah mau menjalankan mason get
  final runMason = Confirm(
    prompt: 'Do you want to run "mason get"?',
    defaultValue: true,
  ).interact();

  if (runMason) {
    print('🚀 Running "mason get"...');
    await shell.run('mason get');
  } else {
    print('⚠️  Skipping "mason get".');
  }

  // Tanya user apakah mau menjalankan build_runner
  final runBuildRunner = Confirm(
    prompt: 'Do you want to run "dart run build_runner build --delete-conflicting-outputs"?',
    defaultValue: true,
  ).interact();

  if (runBuildRunner) {
    print('🚀 Running "build_runner"...');
    await shell.run('dart run build_runner build --delete-conflicting-outputs');
  } else {
    print('⚠️  Skipping "build_runner".');
  }
}

Future<void> handleExistingProject(String projectName) async {
  final projectDir = Directory(projectName);
  if (await projectDir.exists()) {
    final overwrite = Confirm(
      prompt: 'Project "$projectName" already exists. Do you want to delete and recreate it?',
      defaultValue: false,
    ).interact();

    if (!overwrite) {
      print('❌ Project creation cancelled.');
      exit(0);
    }

    // Hapus folder lama
    await projectDir.delete(recursive: true);
    print('🗑️  Existing project "$projectName" deleted.');
  }
}

Future<void> installFlutterFromFvmrc(Shell shell) async {
  final fvmrcFile = File('.fvmrc');
  if (await fvmrcFile.exists()) {
    // Baca file .fvmrc
    final content = await fvmrcFile.readAsString();
    try {
      final decoded = jsonDecode(content);
      final flutterVersion = decoded['flutter'];
      if (flutterVersion != null) {
        print('🚀  Installing Flutter version "$flutterVersion" from .fvmrc via FVM...');
        await shell.run('fvm install $flutterVersion --setup');
        print('🐣  Flutter version "$flutterVersion" installed successfully!');
        await shell.run('fvm use');
        print('🐣  FVM is now using Flutter version "$flutterVersion"');
      } else {
        print('⚠️  .fvmrc does not contain "flutter" key. Skipping FVM install.');
      }
    } catch (e) {
      print('⚠️  Failed to parse .fvmrc: $e');
    }
  } else {
    print('⚠️  No .fvmrc found. Skipping FVM install.');
  }
}
