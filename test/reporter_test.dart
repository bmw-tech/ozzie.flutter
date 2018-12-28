import 'dart:io';
import 'package:test/test.dart';
import 'package:ozzie/reporter.dart';

void main() {
  final testFolder = "test_folder";
  Reporter reporter;

  setUp(() async {
    reporter = Reporter();
    await File('$testFolder/alex/a.png').create(recursive: true);
    await File('$testFolder/alex/b.png').create(recursive: true);
    await File('$testFolder/rim/charity.png').create(recursive: true);
  });

  tearDown(() async {
    if (await Directory(testFolder).exists()) {
      await Directory(testFolder).delete(recursive: true);
    }
  });

  test('generates HTML report on the given folder', () async {
    await reporter.generateHtmlReport(
      rootFolderName: testFolder,
      groupName: 'test',
    );
    final isHtmlReportGenerated = await File('$testFolder/index.html').exists();
    expect(true, isHtmlReportGenerated);
  });
}
