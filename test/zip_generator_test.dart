import 'dart:io';
import 'package:test/test.dart';
import 'package:ozzie/zip_generator.dart';

void main() {
  final testFolder = "test_folder";
  ZipGenerator zipGenerator;

  setUp(() async {
    zipGenerator = ZipGenerator();
    await Directory(testFolder).create();
    await File('./assets/ozzie.zip').copy('$testFolder/ozzie.zip');
  });

  tearDown(() async {
    if (await Directory(testFolder).exists()) {
      await Directory(testFolder).delete(recursive: true);
    }
  });

  test('generateZipInFolder', () async {
    await zipGenerator.generateZipInFolder(
      groupFolderName: testFolder,
      groupName: 'testFile',
    );
    final isZipGenerated = await File('$testFolder/testFile.zip').exists();
    expect(isZipGenerated, isTrue);
  });

  test('generateZipWithAllGroups', () async {
    await zipGenerator.generateZipWithAllGroups(rootFolder: testFolder);
    final isZipGenerated = await File('$testFolder/ozzie.zip').exists();
    expect(isZipGenerated, isTrue);
  });
}
