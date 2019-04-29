import 'package:meta/meta.dart';
import 'dart:convert';

class TimelineSummaryReport {
  final double averageFrameBuildTimeMillis;
  final double th90PercentileFrameBuildTimeMillis;
  final double th99PercentileFrameBuildTimeMillis;
  final double worstFrameBuildTimeMillis;
  final int missedFrameBuildBudgetCount;
  final double averageFrameRasterizerTimeMillis;
  final double th90percentileFrameRasterizerTimeMillis;
  final double th99percentileFrameRasterizerTimeMillis;
  final double worstFrameRasterizerTimeMillis;
  final int missedFrameRasterizerBudgetCount;
  final int frameCount;
  final List<int> frameBuildTimes;
  final List<int> frameRasterizerTimes;

  TimelineSummaryReport({
    @required this.averageFrameBuildTimeMillis,
    @required this.th90PercentileFrameBuildTimeMillis,
    @required this.th99PercentileFrameBuildTimeMillis,
    @required this.worstFrameBuildTimeMillis,
    @required this.missedFrameBuildBudgetCount,
    @required this.averageFrameRasterizerTimeMillis,
    @required this.th90percentileFrameRasterizerTimeMillis,
    @required this.th99percentileFrameRasterizerTimeMillis,
    @required this.worstFrameRasterizerTimeMillis,
    @required this.missedFrameRasterizerBudgetCount,
    @required this.frameCount,
    @required this.frameBuildTimes,
    @required this.frameRasterizerTimes,
  });

  factory TimelineSummaryReport.fromJson(Map<String, dynamic> json) {
    return TimelineSummaryReport(
      averageFrameBuildTimeMillis: json['average_frame_build_time_millis'],
      th90PercentileFrameBuildTimeMillis:
          json['90th_percentile_frame_build_time_millis'],
      th99PercentileFrameBuildTimeMillis:
          json['99th_percentile_frame_build_time_millis'],
      worstFrameBuildTimeMillis: json['worst_frame_build_time_millis'],
      missedFrameBuildBudgetCount: json['missed_frame_build_budget_count'],
      averageFrameRasterizerTimeMillis:
          json['average_frame_rasterizer_time_millis'],
      th90percentileFrameRasterizerTimeMillis:
          json['90th_percentile_frame_rasterizer_time_millis'],
      th99percentileFrameRasterizerTimeMillis:
          json['99th_percentile_frame_rasterizer_time_millis'],
      worstFrameRasterizerTimeMillis:
          json['worst_frame_rasterizer_time_millis'],
      missedFrameRasterizerBudgetCount:
          json['missed_frame_rasterizer_budget_count'],
      frameCount: json['frame_count'],
      frameBuildTimes: _toIntList(json['frame_build_times']),
      frameRasterizerTimes: _toIntList(json['frame_rasterizer_times']),
    );
  }

  factory TimelineSummaryReport.fromStringContent(String summaryContent) {
    final json = jsonDecode(summaryContent);
    return TimelineSummaryReport.fromJson(json);
  }

  static List<int> _toIntList(List<dynamic> items) =>
      items.map((i) => i as int).toList();
}
