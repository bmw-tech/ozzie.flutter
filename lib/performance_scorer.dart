import 'models/models.dart';

/// Class responsible for scoring the performance of features
class PerformanceScorer {
  /// It gives an overall [PerformanceScore] for the the different
  /// reports given
  static PerformanceScore score(
    String reportName,
    List<PerformanceReport> reports,
  ) {
    final missedFramesScore = scoreMissedFrames(reports);
    final frameBuildRateScore = scoreFrameBuildRate(reports);
    final frameRasterizerRateScore = scoreFrameRasterizerRate(reports);
    print('[ozzie-performance] Performance report for ${reportName}');
    print('[ozzie-performance] Missed Frames: $missedFramesScore');
    print('[ozzie-performance] Frame Build Rate: $frameBuildRateScore');
    print(
        '[ozzie-performance] Frame Rasterizer Rate: $frameRasterizerRateScore');
    return PerformanceScore(
      frameBuildRate: frameBuildRateScore,
      missedFrames: missedFramesScore,
      frameRasterizerRate: frameRasterizerRateScore,
    );
  }

  /// It gives a [Score] about missed frames for the given `reports`
  static Score scoreMissedFrames(List<PerformanceReport> reports) {
    if (reports == null || reports.isEmpty) return null;
    final totalFrames = reports
        .map((r) => r.summaryReportContent.frameCount)
        .reduce((count, element) => count + element);
    final missedFrames = reports
        .map((r) => r.summaryReportContent.missedFrameBuildBudgetCount)
        .reduce((count, element) => count + element);
    return _scoreMissedFrames(totalFrames, missedFrames);
  }

  /// It gives a [Score] about the frame build rate for the given `reports`
  static Score scoreFrameBuildRate(List<PerformanceReport> reports) {
    if (reports == null || reports.isEmpty) return null;
    final totalOfAverageBuildTimes = reports
        .map((r) => r.summaryReportContent.averageFrameBuildTimeMillis)
        .reduce((value, element) => value + element);
    final totalReports = reports.length;
    return _scoreFrameBuildRate(totalReports, totalOfAverageBuildTimes);
  }

  /// It gives a [Score] about the frame rasterizer rate for the given `reports`
  static Score scoreFrameRasterizerRate(List<PerformanceReport> reports) {
    if (reports == null || reports.isEmpty) return null;
    final totalOfAverageRasterizerTimes = reports
        .map((r) => r.summaryReportContent.averageFrameRasterizerTimeMillis)
        .reduce((value, element) => value + element);
    final totalReports = reports.length;
    return _scoreFrameRasterizerRate(
      totalReports,
      totalOfAverageRasterizerTimes,
    );
  }

  /// It gives a [PerformanceScore] for the given `report`
  static PerformanceScore scoreSummary(TimelineSummaryReport report) {
    if (report == null) return null;
    final missedFramesScore = scoreMissedFramesOnSummary(report);
    final frameBuildRateScore = scoreFrameBuildRateOnSummary(report);
    final frameRasterizerRateScore = scoreFrameRasterizerRateOnSummary(report);
    return PerformanceScore(
      frameBuildRate: frameBuildRateScore,
      missedFrames: missedFramesScore,
      frameRasterizerRate: frameRasterizerRateScore,
    );
  }

  /// It gives a [Score] about missed frames for the given `report`
  static Score scoreMissedFramesOnSummary(TimelineSummaryReport report) {
    if (report == null) return null;
    final totalFrames = report.frameCount;
    final missedFrames = report.missedFrameBuildBudgetCount;
    return _scoreMissedFrames(totalFrames, missedFrames);
  }

  /// It gives a [Score] about the frame build rate for the given `report`
  static Score scoreFrameBuildRateOnSummary(TimelineSummaryReport report) {
    if (report == null) return null;
    return _scoreFrameBuildRate(1, report.averageFrameBuildTimeMillis);
  }

  /// It gives a [Score] about the frame rasterizer rate for the given `reports`
  static Score scoreFrameRasterizerRateOnSummary(
    TimelineSummaryReport report,
  ) {
    if (report == null) return null;
    return _scoreFrameRasterizerRate(
      1,
      report.averageFrameRasterizerTimeMillis,
    );
  }

  static Score _scoreMissedFrames(
    int totalFrames,
    int missedFrames,
  ) {
    final missedPercentage = (missedFrames / totalFrames * 100);
    final infoMessage =
        'The percentage of missed frames is $missedPercentage % (Total: $totalFrames, missed: $missedFrames)';
    if (missedPercentage > 10) return Score(Rating.failure, infoMessage);
    if (missedPercentage > 5) return Score(Rating.warning, infoMessage);
    return Score(Rating.success, infoMessage);
  }

  static Score _scoreFrameBuildRate(
      int totalReports, double totalOfAverageBuildTimes) {
    final totalAverage = totalOfAverageBuildTimes / totalReports;
    final infoMessage =
        'The average_frame_build_time_millis of this feature is $totalAverage';
    if (totalAverage > 16) return Score(Rating.failure, infoMessage);
    if (totalAverage > 14) {
      return Score(
        Rating.warning,
        'Watch out! This is really close to 16 ms -> $infoMessage',
      );
    }
    return Score(Rating.success, 'Getting 60fps => $infoMessage');
  }

  static Score _scoreFrameRasterizerRate(
    int totalReports,
    double totalOfAverageRasterizerTimes,
  ) {
    final totalAverage = totalOfAverageRasterizerTimes / totalReports;
    final infoMessage =
        'The average_frame_rasterizer_time_millis of this feature is $totalAverage';
    if (totalAverage > 16) return Score(Rating.failure, infoMessage);
    if (totalAverage > 14) {
      return Score(
        Rating.warning,
        'Watch out! This is really close to 16 ms -> $infoMessage',
      );
    }
    return Score(Rating.success, 'Getting 60fps => $infoMessage');
  }
}
