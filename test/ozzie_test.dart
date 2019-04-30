import 'dart:async';
import 'dart:io';
import 'package:test/test.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:ozzie/ozzie.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';

class MockFlutterDriver extends Mock implements FlutterDriver {}

class MockTimeline extends Mock implements Timeline {}

void main() {
  Ozzie ozzie;
  FlutterDriver driver;
  final testGroupName = 'bender';
  final timeline = MockTimeline();

  setUp(() {
    driver = MockFlutterDriver();
    ozzie = Ozzie.initWith(driver, groupName: testGroupName);
    when(driver.screenshot()).thenAnswer((_) => Future.value([1, 2, 3]));
    when(driver.traceAction(any)).thenAnswer((_) => Future.value(timeline));
    final timelineJson =
        jsonDecode(File('./assets/timeline.json').readAsStringSync());
    final model = Timeline.fromJson(timelineJson);
    when(timeline.events).thenReturn(model.events);
  });

  tearDown(() async {
    if (await Directory(rootFolderName).exists()) {
      await Directory(rootFolderName).delete(recursive: true);
    }
  });

  group('Ozzie', () {
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

    test('not taking screenshots still generates an HTML report', () async {
      await ozzie.generateHtmlReport();
      final fileExists = await File('$rootFolderName/index.html').exists();
      expect(fileExists, isTrue);
    });

    test('profilePerformance writes a performance summary and timeline',
        () async {
      await ozzie.profilePerformance('myreport', () async {
        await print('profiling');
      });
      verify(driver.traceAction(any)).called(1);
    });

    group('with screenshots enabled', () {
      test('on first takeScreenshot call the the group folder is deleted',
          () async {
        final filePath = '$rootFolderName/$testGroupName';
        var testFile = await File('$filePath/testFile').create(recursive: true);
        testFile.writeAsBytes([1, 2, 3]);
        await ozzie.takeScreenshot('alex');
        final doesTestFileStillExists =
            await File('$filePath/testFile').exists();
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

      group('HTML report generation', () {
        test('not calling generateHtmlReport does not create index.html',
            () async {
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
    });

    group('with screenshots disabled', () {
      test('should not take any screenshots', () async {
        final noScreenshotsOzzie = Ozzie.initWith(
          driver,
          shouldTakeScreenshots: false,
        );
        await noScreenshotsOzzie.takeScreenshot('test');
        verifyNever(driver.screenshot());
      });

      test('should not generate an HTML report', () async {
        final noScreenshotsOzzie = Ozzie.initWith(
          driver,
          shouldTakeScreenshots: false,
        );
        await noScreenshotsOzzie.takeScreenshot('alex');
        final isHtmlReportGenerated =
            await File('$rootFolderName/index.html').exists();
        expect(false, isHtmlReportGenerated);
      });
    });
  });
}
