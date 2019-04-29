import 'package:meta/meta.dart';

import 'models.dart';

class OzzieReport {
  final String reportName;
  final List<String> screenshots;
  final List<PerformanceReport> performanceReports;

  OzzieReport({
    @required this.reportName,
    @required this.screenshots,
    @required this.performanceReports,
  });
}
