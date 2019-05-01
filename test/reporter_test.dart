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

  test('generates HTML report on the given folder without performance reports',
      () async {
    await reporter.generateHtmlReport(
      rootFolderName: testFolder,
      groupName: 'test',
    );
    final isHtmlReportGenerated = await File('$testFolder/index.html').exists();
    expect(true, isHtmlReportGenerated);
  });

  test('generates HTML report on the given folder with performance reports',
      () async {
    final config = """
integration_test_expectations:
  should_fail_build_on_warning: false
  should_fail_build_on_error: false
performance_metrics:
  missed_frames_threshold:
    warning_percentage: 5.0
    error_percentage: 10.0
  frame_build_rate_threshold:
    warning_time_in_millis: 14.0
    error_time_in_millis: 16.0
  frame_rasterizer_rate_threshold:
    warning_time_in_millis: 14.0
    error_time_in_millis: 16.0
    """;
    await File('ozzie.yaml').create()
      ..writeAsStringSync(config);
    final fileContents =
        File('./assets/timeline_summary.json').readAsStringSync();
    await File('$testFolder/alex/profiling/a.timeline.json')
        .create(recursive: true);
    await File('$testFolder/alex/profiling/b.timeline.json')
        .create(recursive: true);
    final aJson =
        await File('$testFolder/alex/profiling/a.timeline_summary.json')
            .create(recursive: true);
    final bJson =
        await File('$testFolder/alex/profiling/b.timeline_summary.json')
            .create(recursive: true);
    aJson.writeAsStringSync(fileContents);
    bJson.writeAsStringSync(fileContents);
    await reporter.generateHtmlReport(
      rootFolderName: testFolder,
      groupName: 'test',
    );
    final isHtmlReportGenerated = await File('$testFolder/index.html').exists();
    expect(true, isHtmlReportGenerated);
    await File('ozzie.yaml').delete();
  });
}
