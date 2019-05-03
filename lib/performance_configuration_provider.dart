import 'dart:async';
import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:ozzie/models/models.dart';

/// Class responsible from getting the configuration from a file
/// named `ozzie.yaml` at the root of the project, or provide a
/// default [PerformanceConfiguration] object instead
class PerformanceConfigurationProvider {
  static final _defaultShouldFailBuildOnWarning = false;
  static final _defaultShouldFailBuildOnError = true;
  static final _defaultMissedFramesErrorPercentage = 10.0;
  static final _defaultMissedFramesWarningPercentage = 5.0;
  static final _defaultFrameBuildRateErrorThresholdInMills = 16.0;
  static final _defaultFrameBuildRateWarningThresholdInMills = 14.0;
  static final _defaultFrameBuildRasterizerErrorThresholdInMills = 16.0;
  static final _defaultFrameBuildRasterizerWarningThresholdInMills = 14.0;

  static final _integrationTestExpectationsKey =
      'integration_test_expectations';
  static final _shouldFailBuildOnWarningKey = 'should_fail_build_on_warning';
  static final _shouldFailBuildOnErrorKey = 'should_fail_build_on_error';
  static final _performanceMetricsKey = 'performance_metrics';
  static final _missedFramesThresholdKey = 'missed_frames_threshold';
  static final _missedFramesErrorPercentageKey = 'error_percentage';
  static final _missedFramesWarningPercentageKey = 'warning_percentage';
  static final _frameBuildRateThresholdKey = 'frame_build_rate_threshold';
  static final _frameBuildRateErrorKey = 'error_time_in_millis';
  static final _frameBuildRateWarningKey = 'warning_time_in_millis';
  static final _frameRasterizerRateThresholdKey =
      'frame_rasterizer_rate_threshold';
  static final _frameRasterizerRateErrorKey = 'error_time_in_millis';
  static final _frameRasterizerWarningKey = 'warning_time_in_millis';

  /// Default [PerformanceConfiguration] values
  static PerformanceConfiguration get defaultPerformanceConfiguration {
    return PerformanceConfiguration(
      shouldFailBuildOnWarning: _defaultShouldFailBuildOnWarning,
      shouldFailBuildOnError: _defaultShouldFailBuildOnError,
      missedFramesThreshold: MissedFramesThreshold(
        errorPercentage: _defaultMissedFramesErrorPercentage,
        warningPercentage: _defaultMissedFramesWarningPercentage,
      ),
      frameBuildRateThreshold: FrameRateThreshold(
        errorTimeInMills: _defaultFrameBuildRateErrorThresholdInMills,
        warningTimeInMills: _defaultFrameBuildRateWarningThresholdInMills,
      ),
      frameRasterizerRateThreshold: FrameRateThreshold(
        errorTimeInMills: _defaultFrameBuildRasterizerErrorThresholdInMills,
        warningTimeInMills: _defaultFrameBuildRasterizerWarningThresholdInMills,
      ),
    );
  }

  /// It will provide the values determined in `ozzie.yaml`, or the
  /// default values in case they are not defined.
  static Future<PerformanceConfiguration> provide() async {
    final configFile = File('ozzie.yaml');
    if (!await configFile.exists()) return defaultPerformanceConfiguration;
    final fileContents = configFile.readAsStringSync();
    return _parseYamlConfigFile(fileContents);
  }

  static PerformanceConfiguration _parseYamlConfigFile(String fileContents) {
    try {
      final yaml = loadYaml(fileContents);
      final performanceMetrics = yaml[_performanceMetricsKey];
      final missedFrames = performanceMetrics[_missedFramesThresholdKey];
      final errorMissedFrames = missedFrames[_missedFramesErrorPercentageKey] ??
          _defaultMissedFramesErrorPercentage;
      final warningMissedFrames =
          missedFrames[_missedFramesWarningPercentageKey] ??
              _defaultMissedFramesWarningPercentage;
      final frameBuildRate = performanceMetrics[_frameBuildRateThresholdKey];
      final errorFrameBuildRate = frameBuildRate[_frameBuildRateErrorKey] ??
          _defaultFrameBuildRateErrorThresholdInMills;
      final warningFrameBuildRate = frameBuildRate[_frameBuildRateWarningKey] ??
          _defaultFrameBuildRateWarningThresholdInMills;
      final frameRasterizerRate =
          performanceMetrics[_frameRasterizerRateThresholdKey];
      final errorFrameRasterizerRate =
          frameRasterizerRate[_frameRasterizerRateErrorKey] ??
              _defaultFrameBuildRasterizerErrorThresholdInMills;
      final warningFrameRasterizerRate =
          frameRasterizerRate[_frameRasterizerWarningKey] ??
              _defaultFrameBuildRasterizerWarningThresholdInMills;
      final integrationTestExpectations = yaml[_integrationTestExpectationsKey];
      final shouldFailBuildOnWarning =
          integrationTestExpectations[_shouldFailBuildOnWarningKey] ??
              _defaultShouldFailBuildOnWarning;
      final shouldFailBuildOnError =
          integrationTestExpectations[_shouldFailBuildOnErrorKey] ??
              _defaultShouldFailBuildOnError;
      return PerformanceConfiguration(
        shouldFailBuildOnError: shouldFailBuildOnError,
        shouldFailBuildOnWarning: shouldFailBuildOnWarning,
        missedFramesThreshold: MissedFramesThreshold(
          errorPercentage: errorMissedFrames,
          warningPercentage: warningMissedFrames,
        ),
        frameBuildRateThreshold: FrameRateThreshold(
          errorTimeInMills: errorFrameBuildRate,
          warningTimeInMills: warningFrameBuildRate,
        ),
        frameRasterizerRateThreshold: FrameRateThreshold(
          errorTimeInMills: errorFrameRasterizerRate,
          warningTimeInMills: warningFrameRasterizerRate,
        ),
      );
    } catch (_) {
      return defaultPerformanceConfiguration;
    }
  }
}
