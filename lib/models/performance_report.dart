import 'package:meta/meta.dart';

import 'models.dart';

/// Model that encapsulates different performance metrics of a feature
class PerformanceReport {
  final String testName;
  final String timelineReport;
  final String timelineSummaryReport;
  final String summaryRawContent;
  final TimelineSummaryReport summaryReportContent;
  final PerformanceScore score;

  PerformanceReport({
    @required this.testName,
    @required this.timelineReport,
    @required this.timelineSummaryReport,
    @required this.summaryRawContent,
    @required this.summaryReportContent,
    @required this.score,
  });
}
