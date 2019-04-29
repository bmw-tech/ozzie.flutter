import 'package:meta/meta.dart';

import 'models.dart';

class PerformanceReport {
  final String testName;
  final String timelineReport;
  final String timelineSummaryReport;
  final String summaryRawContent;
  final TimelineSummaryReport summaryReportContent;

  PerformanceReport({
    @required this.testName,
    @required this.timelineReport,
    @required this.timelineSummaryReport,
    @required this.summaryRawContent,
    @required this.summaryReportContent,
  });
}
