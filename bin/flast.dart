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
  final shell = Shell();

  // Tanya apakah menggunakan FVM
  final useFvm = Confirm(prompt: 'Do you want to use FVM?', defaultValue: false).interact();

  final flutterCmd = useFvm ? 'fvm flutter' : 'flutter';
  // final dartCmd = useFvm ? 'fvm dart' : 'dart';

  // Prompt data dari user
  final org = Input(prompt: 'What is your organization?', defaultValue: 'com.example').interact();

  final platformsSelection =
      MultiSelect(
        prompt: 'Choose platforms (use ↑/↓ to navigate, space to select, enter to confirm)',
        options: ['android', 'ios', 'web', 'windows', 'linux', 'macos'],
        defaults: [true, true, true, false, false, false],
      ).interact();

  final platforms =
      [
        'android',
        'ios',
        'web',
        'windows',
        'linux',
        'macos',
      ].asMap().entries.where((e) => platformsSelection.contains(e.key)).map((e) => e.value).toList();

  final projectName = Input(prompt: 'What is your project name?', defaultValue: 'my_app').interact();

  String flutterVersion = 'stable';
  if (useFvm) {
    flutterVersion =
        Input(prompt: 'Flutter version for FVM (e.g. 3.32.5 or stable)', defaultValue: 'stable').interact();
  }

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
    final updatedLines =
        lines.map((line) {
          if (line.trim().startsWith('name:')) {
            return 'name: $projectName';
          }
          return line;
        }).toList();

    pubspecFile.writeAsStringSync(updatedLines.join('\n'));
    print('✅ Pubspec.yaml updated successfully!');
  }

  // Hapus git lama dan init ulang
  await shell.run('rm -rf .git');
  await shell.run('git init');

  // Copy .env.example jika ada
  if (File('.env.example').existsSync()) {
    await shell.run('cp .env.example .env');
  }

  // Hapus semua platform lama
  for (var platform in ['android', 'ios', 'web', 'windows', 'linux', 'macos']) {
    await shell.run('rm -rf $platform');
  }

  // Install Flutter versi yang diminta via FVM (jika dipilih)
  if (useFvm) {
    await shell.run('fvm install $flutterVersion');
  }

  // Jalankan flutter create dengan bahasa yang dipilih
  await shell.run(
    '$flutterCmd create --org $org --platforms ${platforms.join(",")} '
    '--android-language $androidLang --ios-language $iosLang .',
  );

  print('✅ Project $projectName created successfully!');
  print('cd $projectName');
  print(useFvm ? 'fvm flutter run' : 'flutter run');
}
