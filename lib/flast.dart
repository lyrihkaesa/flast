library;

export 'cli.dart';
export 'commands/create.dart';
export 'commands/post_setup.dart';
export 'commands/install.dart';
export 'utils/file_ops.dart';
export 'utils/logger.dart';

import 'cli.dart';

Future<void> runFlast(List<String> args) async {
  await runCli(args);
}
