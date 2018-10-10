import 'dart:async';
import 'dart:io';
import 'package:test/test.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:ozzie/ozzie.dart';
import 'package:mockito/mockito.dart';

class MockFlutterDriver extends Mock implements FlutterDriver {}

void main() {
  Ozzie ozzie;
  final FlutterDriver driver = MockFlutterDriver();
  final testGroupName = 'bender';

  setUp(() {
    ozzie = Ozzie.initWith(driver, groupName: testGroupName);
    when(driver.screenshot()).thenAnswer((_) => Future.value([1, 2, 3]));
  });

  tearDown(() async {
    if (await Directory(rootFolderName).exists()) {
      await Directory(rootFolderName).delete(recursive: true);
    }
  });

  group('Constructor', () {
    test('a null driver throws an exception', () {
      expect(() => Ozzie.initWith(null, groupName: ''),
          throwsA(TypeMatcher<AssertionError>()));
    });

    test('group name is the one passed as a dependency', () {
      expect(ozzie.groupName, testGroupName);
    });

    test('driver is the one passed as a dependency', () {
      expect(ozzie.driver, driver);
    });
  });

  group('Screenshots', () {
    test('on first takeScreenshot call the the group folder is deleted',
        () async {
      final filePath = '$rootFolderName/$testGroupName';
      var testFile = await File('$filePath/testFile').create(recursive: true);
      testFile.writeAsBytes([1, 2, 3]);
      await ozzie.takeScreenshot('alex');
      final doesTestFileStillExists = await File('$filePath/testFile').exists();
      expect(false, doesTestFileStillExists);
    });

    test('takeScreenshots relies on the driver to take the screenshot',
        () async {
      await ozzie.takeScreenshot('test');
      verify(driver.screenshot());
    });

    test('takeScreenshot generates PNGs containing given name', () async {
      await ozzie.takeScreenshot('rim');
      final files =
          Directory('$rootFolderName/$testGroupName').listSync().toList();
      final resultFile =
          files.where((f) => f is File).map((f) => f as File).first;
      expect(true, resultFile.path.contains('rim.png'));
    });
  });

  group('HTML report generation', () {
    test('not calling generateHtmlReport does not create index.html', () async {
      await ozzie.takeScreenshot('alex');
      final isHtmlReportGenerated =
          await File('$rootFolderName/index.html').exists();
      expect(false, isHtmlReportGenerated);
    });

    test('generateHtmlReport creates an index.html at the root', () async {
      await ozzie.takeScreenshot('alex');
      await ozzie.generateHtmlReport();
      final isHtmlReportGenerated =
          await File('$rootFolderName/index.html').exists();
      expect(true, isHtmlReportGenerated);
    });
  });
}
