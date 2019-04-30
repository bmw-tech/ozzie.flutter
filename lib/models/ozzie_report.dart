import 'package:meta/meta.dart';

import 'models.dart';

/// Model than encapsulates different metrics for a feature report
class OzzieReport {
  final String reportName;
  final List<String> screenshots;
  final List<PerformanceReport> performanceReports;
  final PerformanceScore performanceScore;

  OzzieReport({
    @required this.reportName,
    @required this.screenshots,
    @required this.performanceReports,
    @required this.performanceScore,
  });
}
