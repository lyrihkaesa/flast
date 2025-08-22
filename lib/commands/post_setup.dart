import 'package:interact/interact.dart';
import 'package:process_run/shell.dart';

import '../utils/logger.dart';

Future<Map<String, bool>> runPostSetup({
  required Shell shell,
  bool useFvm = false,
  bool interactive = true,
  bool skipPubGet = false,
}) async {
  bool isRunMason = false;
  bool isRunBuildRunner = false;

  if (interactive) {
    // Mason
    final runMason = Confirm(
      prompt: 'Do you want to run "mason get"?',
      defaultValue: true,
    ).interact();

    if (runMason) {
      printBoxMessage('♦ Running "mason get"...');
      await shell.run('mason get');
      isRunMason = true;
    } else {
      printBoxMessage('○ Skipping "mason get".');
    }

    // Build Runner
    if (!skipPubGet) {
      final runBuildRunner = Confirm(
        prompt: 'Do you want to run build_runner?',
        defaultValue: true,
      ).interact();

      if (runBuildRunner) {
        printBoxMessage('♦ Running "build_runner"...');
        final fvm = useFvm ? 'fvm ' : '';
        await shell.run('${fvm}dart run build_runner build --delete-conflicting-outputs');
        isRunBuildRunner = true;
      } else {
        printBoxMessage('○ Skipping build_runner.');
      }
    } else {
      printBoxMessage('○ Skipping build_runner "--no-pub".');
    }
  } else {
    printBoxMessage('○ Post-setup skipped (interactive prompts disabled).');
  }

  return {
    'isRunMason': isRunMason,
    'isRunBuildRunner': isRunBuildRunner,
  };
}
