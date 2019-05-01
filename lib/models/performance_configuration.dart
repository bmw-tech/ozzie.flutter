import 'package:meta/meta.dart';

/// Model that holds the threshold values for the performance report
class PerformanceConfiguration {
  final MissedFramesThreshold missedFramesThreshold;
  final FrameRateThreshold frameBuildRateThreshold;
  final FrameRateThreshold frameRasterizerRateThreshold;

  PerformanceConfiguration({
    @required this.missedFramesThreshold,
    @required this.frameBuildRateThreshold,
    @required this.frameRasterizerRateThreshold,
  });
}

/// Model that holds the threshold values for missed frames
class MissedFramesThreshold {
  final double errorPercentage;
  final double warningPercentage;

  MissedFramesThreshold({
    @required this.errorPercentage,
    @required this.warningPercentage,
  });
}

/// Model that holds the threshold values for frame analysis
class FrameRateThreshold {
  final double errorTimeInMills;
  final double warningTimeInMills;

  FrameRateThreshold({
    @required this.errorTimeInMills,
    @required this.warningTimeInMills,
  });
}
