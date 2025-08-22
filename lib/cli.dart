import 'dart:io';
import 'package:args/args.dart';

import 'commands/create.dart';
import 'version.dart';

// Helper: tambahkan flag umum (help, version)
ArgParser withCommonFlags([ArgParser? parser]) {
  final p = parser ?? ArgParser();
  p.addFlag(
    'help',
    abbr: 'h',
    help: 'Show usage information',
    negatable: false,
  );
  p.addFlag(
    'version',
    abbr: 'v',
    help: 'Show version information',
    negatable: false,
  );
  return p;
}

Future<void> runCli(List<String> arguments) async {
  final parser = withCommonFlags(ArgParser());

  // Subcommand create
  final createParser = withCommonFlags(ArgParser()
    ..addFlag(
      'force',
      abbr: 'f',
      help: 'Force overwrite existing project',
      negatable: false,
    ));

  parser.addCommand('create', createParser);

  // Parse
  final results = parser.parse(arguments);

  // Cek global flags dulu
  if (results['help'] == true) {
    _printGlobalUsage(parser);
    exit(0);
  }
  if (results['version'] == true) {
    _printVersion();
    exit(0);
  }

  // Handle subcommand
  switch (results.command?.name) {
    case 'create':
      final createArgs = results.command!;
      if (createArgs['help'] == true) {
        _printCreateUsage(createParser);
        exit(0);
      }
      if (createArgs['version'] == true) {
        _printVersion();
        exit(0);
      }

      final force = createArgs['force'] as bool;
      await createProject(force: force);
      break;

    default:
      _printGlobalUsage(parser);
      exit(64); // 64: usage error
  }
}

// Print global usage
void _printGlobalUsage(ArgParser parser) {
  print('''
Usage: flast <command> [options]

Global options:
${parser.usage}

Available commands:
  create   Create a new project
''');
}

// Print create usage
void _printCreateUsage(ArgParser parser) {
  print('''
Usage: flast create [options]

Options:
${parser.usage}
''');
}

// Print version
void _printVersion() {
  print('flast v$packageVersion');
}
