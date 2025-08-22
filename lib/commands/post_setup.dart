import 'package:interact/interact.dart';
import 'package:process_run/shell.dart';

Future<void> runPostSetup({
  required Shell shell,
  bool useFvm = false,
  bool interactive = true, // <-- tambahkan ini
}) async {
  if (interactive) {
    final runMason = Confirm(
      prompt: 'Do you want to run "mason get"?',
      defaultValue: true,
    ).interact();

    if (runMason) {
      print('🚀 Running "mason get"...');
      await shell.run('mason get');
    } else {
      print('⚠️ Skipping "mason get".');
    }

    final runBuildRunner = Confirm(
      prompt: 'Do you want to run build_runner?',
      defaultValue: true,
    ).interact();

    if (runBuildRunner) {
      print('🚀 Running build_runner...');
      await shell.run('dart run build_runner build --delete-conflicting-outputs');
    } else {
      print('⚠️ Skipping build_runner.');
    }
  } else {
    print('ℹ️ Post-setup skipped (interactive prompts disabled).');
  }
}
