import 'dart:io';
import 'package:hive/hive.dart';

Future<void> setupTestHive() async {
  final testDir = Directory('${Directory.current.path}/test/hive_testing_temp');
  if (!testDir.existsSync()) {
    testDir.createSync(recursive: true);
  }
  Hive.init(testDir.path);
}
