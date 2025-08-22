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
  final createParser = withCommonFlags(ArgParser()
    ..addFlag('force', abbr: 'f', help: 'Force overwrite existing project', negatable: false)
    ..addOption('org', abbr: 'o', help: 'Organization for your project')
    ..addOption('platforms', abbr: 'p', help: 'Comma-separated list of platforms (android,ios,web,windows,linux,macos)')
    ..addOption('android-language', abbr: 'a', allowed: ['kotlin', 'java'], help: 'Android language')
    ..addOption('ios-language', abbr: 'i', allowed: ['swift', 'objective-c'], help: 'iOS language'));

  parser.addCommand('create', createParser);

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

      await createProject(
        projectName: projectName,
        org: org,
        platformsCsv: platformsCsv,
        androidLang: androidLang,
        iosLang: iosLang,
        force: force,
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
