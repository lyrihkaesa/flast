import 'dart:io';
import 'package:args/args.dart';
import 'commands/create.dart';
import 'version.dart';

// Tambahkan global flags: help, version
ArgParser withCommonFlags([ArgParser? parser]) {
  final p = parser ?? ArgParser();
  p.addFlag('help', abbr: 'h', help: 'Show usage information', negatable: false);
  p.addFlag('version', abbr: 'v', help: 'Show version information', negatable: false);
  return p;
}

Future<void> runCli(List<String> arguments) async {
  final parser = withCommonFlags(ArgParser());

  // Subcommand 'create' dengan flags/options
  final createParser = withCommonFlags(
    ArgParser()
      ..addFlag('force', abbr: 'f', help: 'Force overwrite existing project', negatable: false)
      ..addOption('org', abbr: 'o', help: 'Organization for your project')
      ..addOption('platforms',
          abbr: 'p', help: 'Comma-separated list of platforms (android,ios,web,windows,linux,macos)')
      ..addOption('android-language', abbr: 'a', allowed: ['kotlin', 'java'], help: 'Android language')
      ..addOption('ios-language', abbr: 'i', allowed: ['swift', 'objective-c'], help: 'iOS language')
      ..addFlag('no-pub', help: 'Skip pub get', negatable: false)
      ..addFlag('fvm', abbr: 'm', help: 'Install and use Flutter via FVM based on .fvmrc', negatable: false)
      ..addOption('kit-version', abbr: 't', help: 'Starter kit version/tag (e.g., 3.0.1)')
      ..addOption('kit-repo', abbr: 'r', help: 'Starter kit repo URL')
      ..addFlag('force-download', abbr: 'd', help: 'Force download starter kit even if cached', negatable: false)
      ..addFlag('verbose', help: 'Verbose output', negatable: false)
      ..addFlag('debug', abbr: 'D', help: 'Debug output', negatable: false),
  );

  parser.addCommand('create', createParser);

  // Subcommand 'new' dengan flags/options lebih simple
  final newParser = withCommonFlags(
    ArgParser()
      ..addFlag('force', abbr: 'f', help: 'Force overwrite existing project', negatable: false)
      ..addOption('org', abbr: 'o', help: 'Organization for your project')
      ..addOption('platforms', abbr: 'p', help: 'Comma-separated list of platforms (android,ios,web)')
      ..addFlag('no-pub', help: 'Skip pub get', negatable: false)
      ..addFlag('fvm', abbr: 'm', help: 'Install and use Flutter via FVM based on .fvmrc', negatable: false)
      ..addFlag('force-download', abbr: 'd', help: 'Force download starter kit even if cached', negatable: false)
      ..addFlag('verbose', help: 'Verbose output', negatable: false)
      ..addFlag('debug', abbr: 'D', help: 'Debug output', negatable: false),
  );

  parser.addCommand('new', newParser);

  ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (e) {
    print('❌ ${e.toString()}');
    _printGlobalUsage(parser);
    exit(64);
  }

  // Global flags
  if (results['help'] == true) {
    _printGlobalUsage(parser);
    exit(0);
  }
  if (results['version'] == true) {
    _printVersion();
    exit(0);
  }

  final cmd = results.command;
  if (cmd == null) {
    _printGlobalUsage(parser);
    exit(64);
  }

  switch (cmd.name) {
    case 'create':
      if (cmd['help'] == true) {
        _printCreateUsage(createParser);
        exit(0);
      }
      if (cmd['version'] == true) {
        _printVersion();
        exit(0);
      }

      final projectName = cmd.rest.isNotEmpty ? cmd.rest[0] : null;
      final org = cmd['org'] as String?;
      final platformsCsv = cmd['platforms'] as String?;
      final androidLang = cmd['android-language'] as String?;
      final iosLang = cmd['ios-language'] as String?;
      final force = cmd['force'] as bool? ?? false;
      final useFvm = cmd['fvm'] as bool? ?? false;
      final skipPubGet = cmd['no-pub'] as bool? ?? false;
      final kitVersion = cmd['kit-version'] as String?;
      final kitRepo = cmd['kit-repo'] as String?;
      final forceDownload = cmd['force-download'] as bool?;
      bool verbose = cmd['verbose'] as bool? ?? false;
      bool debug = cmd['debug'] as bool? ?? false;
      if (debug) verbose = true;

      await createProject(
        projectName: projectName,
        org: org,
        platformsCsv: platformsCsv,
        androidLang: androidLang,
        iosLang: iosLang,
        force: force,
        useFvm: useFvm,
        skipPubGet: skipPubGet,
        kitVersion: kitVersion,
        kitRepo: kitRepo,
        forceDownload: forceDownload,
        verbose: verbose,
      );
      break;

    case 'new':
      if (cmd['help'] == true) {
        _printCreateUsage(newParser); // Bisa pakai fungsi yang sama
        exit(0);
      }
      if (cmd['version'] == true) {
        _printVersion();
        exit(0);
      }

      final projectName = cmd.rest.isNotEmpty ? cmd.rest[0] : null;
      final org = cmd['org'] as String?;
      final platformsCsv = cmd['platforms'] as String?;
      final force = cmd['force'] as bool? ?? false;
      final useFvm = cmd['fvm'] as bool? ?? false;
      final skipPubGet = cmd['no-pub'] as bool? ?? false;
      final forceDownload = cmd['force-download'] as bool?;
      bool verbose = cmd['verbose'] as bool? ?? false;
      bool debug = cmd['debug'] as bool? ?? false;
      if (debug) verbose = true;

      await createProject(
        projectName: projectName,
        org: org,
        platformsCsv: platformsCsv,
        androidLang: 'kotlin',
        iosLang: 'swift',
        force: force,
        useFvm: useFvm,
        kitVersion: 'main',
        kitRepo: 'https://github.com/lyrihkaesa/flutter_starter_kit',
        skipPubGet: skipPubGet,
        forceDownload: forceDownload,
        verbose: verbose,
      );
      break;

    default:
      _printGlobalUsage(parser);
      exit(64);
  }
}

// --- Print helpers ---
void _printGlobalUsage(ArgParser parser) {
  print('''
flast v$packageVersion
Usage: flast <command> [options]

Global options:
${parser.usage}

Available commands:
  create   Create a new project
  new      Create a new project for Kaesa Flutter Starter Kit
''');
}

void _printCreateUsage(ArgParser parser) {
  print('''
flast v$packageVersion
Usage: flast create [projectName] [options]

Options:
${parser.usage}
''');
}

void _printVersion() {
  print('flast v$packageVersion');
}
