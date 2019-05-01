import 'dart:io';
import 'package:ozzie/performance_configuration_provider.dart';
import 'package:test/test.dart';

void main() {
  group('PerformanceConfigurationProvider', () {
    test('defaultPerformanceConfiguration gives default values', () {
      final defaultConfig =
          PerformanceConfigurationProvider.defaultPerformanceConfiguration;
      expect(defaultConfig.missedFramesThreshold.warningPercentage, 5.0);
      expect(defaultConfig.missedFramesThreshold.errorPercentage, 10.0);
      expect(defaultConfig.frameBuildRateThreshold.warningTimeInMills, 14.0);
      expect(defaultConfig.frameBuildRateThreshold.errorTimeInMills, 16.0);
      expect(
          defaultConfig.frameRasterizerRateThreshold.warningTimeInMills, 14.0);
      expect(defaultConfig.frameRasterizerRateThreshold.errorTimeInMills, 16.0);
    });

    group('with an ozzie.yaml provided', () {
      group('and the file is empty', () {
        File emptyFile;

        setUp(() async {
          emptyFile = await File('ozzie.yaml').create(recursive: true);
        });

        tearDown(() async {
          await emptyFile.delete(recursive: true);
        });

        test('returns the default configuration', () async {
          final config = await PerformanceConfigurationProvider.provide();
          final defaultConfig =
              PerformanceConfigurationProvider.defaultPerformanceConfiguration;
          expect(
            config.missedFramesThreshold.warningPercentage,
            defaultConfig.missedFramesThreshold.warningPercentage,
          );
          expect(
            config.missedFramesThreshold.errorPercentage,
            defaultConfig.missedFramesThreshold.errorPercentage,
          );
          expect(
            config.frameBuildRateThreshold.warningTimeInMills,
            defaultConfig.frameBuildRateThreshold.warningTimeInMills,
          );
          expect(
            config.frameBuildRateThreshold.errorTimeInMills,
            defaultConfig.frameBuildRateThreshold.errorTimeInMills,
          );
          expect(
            config.frameRasterizerRateThreshold.warningTimeInMills,
            defaultConfig.frameRasterizerRateThreshold.warningTimeInMills,
          );
          expect(
            config.frameRasterizerRateThreshold.errorTimeInMills,
            defaultConfig.frameRasterizerRateThreshold.errorTimeInMills,
          );
        });
      });

      group('and the file has a YAML object', () {
        File yamlFile;

        setUp(() async {
          yamlFile = await File('ozzie.yaml').create(recursive: true);
          yamlFile.writeAsStringSync("""
performance_metrics:
  missed_frames_threshold:
    warning_percentage: 1.0
    error_percentage: 1.5
  frame_build_rate_threshold:
    warning_time_in_millis: 1.0
    error_time_in_millis: 1.5
  frame_rasterizer_rate_threshold:
    warning_time_in_millis: 1.0
    error_time_in_millis: 1.5
          """);
        });

        tearDown(() async {
          await yamlFile.delete(recursive: true);
        });
        test('returns the configuration defined in the file', () async {
          final config = await PerformanceConfigurationProvider.provide();
          expect(config.missedFramesThreshold.warningPercentage, 1.0);
          expect(config.missedFramesThreshold.errorPercentage, 1.5);
          expect(config.frameBuildRateThreshold.warningTimeInMills, 1.0);
          expect(config.frameBuildRateThreshold.errorTimeInMills, 1.5);
          expect(config.frameRasterizerRateThreshold.warningTimeInMills, 1.0);
          expect(config.frameRasterizerRateThreshold.errorTimeInMills, 1.5);
        });
      });
    });

    group('without an ozzie.yaml provided', () {
      test('returns the default configuration', () async {
        final config = await PerformanceConfigurationProvider.provide();
        final defaultConfig =
            PerformanceConfigurationProvider.defaultPerformanceConfiguration;
        expect(
          config.missedFramesThreshold.warningPercentage,
          defaultConfig.missedFramesThreshold.warningPercentage,
        );
        expect(
          config.missedFramesThreshold.errorPercentage,
          defaultConfig.missedFramesThreshold.errorPercentage,
        );
        expect(
          config.frameBuildRateThreshold.warningTimeInMills,
          defaultConfig.frameBuildRateThreshold.warningTimeInMills,
        );
        expect(
          config.frameBuildRateThreshold.errorTimeInMills,
          defaultConfig.frameBuildRateThreshold.errorTimeInMills,
        );
        expect(
          config.frameRasterizerRateThreshold.warningTimeInMills,
          defaultConfig.frameRasterizerRateThreshold.warningTimeInMills,
        );
        expect(
          config.frameRasterizerRateThreshold.errorTimeInMills,
          defaultConfig.frameRasterizerRateThreshold.errorTimeInMills,
        );
      });
    });
  });
}
