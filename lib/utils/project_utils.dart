import 'dart:io';
import 'package:interact/interact.dart';

import 'logger.dart';

/// Cek apakah project sudah ada.
/// Return `true` jika boleh overwrite, `false` jika user batalin.
Future<bool> confirmOverwrite(String projectName, {bool force = false}) async {
  final projectDir = Directory(projectName);

  if (!await projectDir.exists()) {
    return true; // aman, lanjut
  }

  if (force) {
    // skip confirm untuk automation (CI/CD atau --force)
    await projectDir.delete(recursive: true);
    printBoxMessage('♦ Existing project "$projectName" deleted (force).');
    return true;
  }

  final overwrite = Confirm(
    prompt: 'Project "$projectName" already exists. Delete & recreate?',
    defaultValue: false,
  ).interact();

  if (!overwrite) {
    return false;
  }

  await projectDir.delete(recursive: true);
  printBoxMessage('♦ Existing project "$projectName" deleted (force).');
  return true;
}
