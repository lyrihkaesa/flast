import 'dart:io';
import 'package:yaml/yaml.dart';

void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final yaml = loadYaml(pubspec);

  final name = yaml['name'];
  final version = yaml['version'];

  final out = '''
// ⚠️ Generated file. Do not edit.
const packageName = '$name';
const packageVersion = '$version';
''';

  File('lib/version.dart').writeAsStringSync(out);
  print('✅ lib/version.dart updated.');
}
