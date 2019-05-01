import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:ozzie/models/models.dart';
import 'package:ozzie/performance_scorer.dart';

class MockTimelineSummaryReport extends Mock implements TimelineSummaryReport {}

void main() {
  PerformanceScorer performanceScorer;
  setUp(() {
    final configuration = PerformanceConfiguration(
      missedFramesThreshold: MissedFramesThreshold(
        warningPercentage: 5.0,
        errorPercentage: 10.0,
      ),
      frameBuildRateThreshold: FrameRateThreshold(
        warningTimeInMills: 14.0,
        errorTimeInMills: 16.0,
      ),
      frameRasterizerRateThreshold: FrameRateThreshold(
        warningTimeInMills: 14.0,
        errorTimeInMills: 16.0,
      ),
    );
    performanceScorer = PerformanceScorer(configuration);
  });
  group('PerformanceScorer', () {
    List<PerformanceReport> reports;
    TimelineSummaryReport summary1;
    TimelineSummaryReport summary2;
    setUp(() {
      summary1 = MockTimelineSummaryReport();
      summary2 = MockTimelineSummaryReport();
      final report1 = PerformanceReport(
        testName: 'test1',
        timelineReport: 'a',
        timelineSummaryReport: 'a',
        summaryRawContent: '',
        summaryReportContent: summary1,
        score: null,
      );
      final report2 = PerformanceReport(
        testName: 'test2',
        timelineReport: 'b',
        timelineSummaryReport: 'b',
        summaryRawContent: '',
        summaryReportContent: summary2,
        score: null,
      );
      reports = [report1, report2];
    });
    group('for a list of reports', () {
      group('score', () {
        test(
            'gives information about missedFrames, frameBuildRate and frameRasterizerRate',
            () {
          when(summary1.frameCount).thenReturn(50);
          when(summary2.frameCount).thenReturn(50);
          when(summary1.missedFrameBuildBudgetCount).thenReturn(1);
          when(summary2.missedFrameBuildBudgetCount).thenReturn(0);
          when(summary1.averageFrameBuildTimeMillis).thenReturn(2.0);
          when(summary2.averageFrameBuildTimeMillis).thenReturn(4.0);
          when(summary1.averageFrameRasterizerTimeMillis).thenReturn(2.0);
          when(summary2.averageFrameRasterizerTimeMillis).thenReturn(4.0);
          final performanceScore = performanceScorer.score('test', reports);
          expect(performanceScore.missedFrames.rating, Rating.success);
          expect(performanceScore.frameBuildRate.rating, Rating.success);
          expect(performanceScore.frameRasterizerRate.rating, Rating.success);
        });
      });

      group('scoreMissedFrames', () {
        test('Rating is success if percentage is below 5', () {
          when(summary1.frameCount).thenReturn(50);
          when(summary2.frameCount).thenReturn(50);
          when(summary1.missedFrameBuildBudgetCount).thenReturn(1);
          when(summary2.missedFrameBuildBudgetCount).thenReturn(0);
          final score = performanceScorer.scoreMissedFrames(reports);
          expect(score.rating, Rating.success);
          expect(
            score.infoMessage,
            'The percentage of missed frames is 1.0 % (Total: 100, missed: 1)',
          );
        });

        test('Rating is warning if percentage is between 5 and 10', () {
          when(summary1.frameCount).thenReturn(50);
          when(summary2.frameCount).thenReturn(50);
          when(summary1.missedFrameBuildBudgetCount).thenReturn(5);
          when(summary2.missedFrameBuildBudgetCount).thenReturn(3);
          final score = performanceScorer.scoreMissedFrames(reports);
          expect(score.rating, Rating.warning);
          expect(
            score.infoMessage,
            'The percentage of missed frames is 8.0 % (Total: 100, missed: 8)',
          );
        });

        test('Rating is failure if percentage is above 10', () {
          when(summary1.frameCount).thenReturn(50);
          when(summary2.frameCount).thenReturn(50);
          when(summary1.missedFrameBuildBudgetCount).thenReturn(10);
          when(summary2.missedFrameBuildBudgetCount).thenReturn(10);
          final score = performanceScorer.scoreMissedFrames(reports);
          expect(score.rating, Rating.failure);
          expect(
            score.infoMessage,
            'The percentage of missed frames is 20.0 % (Total: 100, missed: 20)',
          );
        });
      });

      group('scoreFrameBuildRate', () {
        test('Rating is success if averageFrameBuildTimeMillis is below 14',
            () {
          when(summary1.averageFrameBuildTimeMillis).thenReturn(2.0);
          when(summary2.averageFrameBuildTimeMillis).thenReturn(4.0);
          final score = performanceScorer.scoreFrameBuildRate(reports);
          expect(score.rating, Rating.success);
          expect(
            score.infoMessage,
            'Getting 60fps => The average_frame_build_time_millis of this feature is 3.0',
          );
        });

        test(
            'Rating is warning if averageFrameBuildTimeMillis is between 14 and 16',
            () {
          when(summary1.averageFrameBuildTimeMillis).thenReturn(15.0);
          when(summary2.averageFrameBuildTimeMillis).thenReturn(15.0);
          final score = performanceScorer.scoreFrameBuildRate(reports);
          expect(score.rating, Rating.warning);
          expect(
            score.infoMessage,
            'Watch out! This is really close to 16 ms -> The average_frame_build_time_millis of this feature is 15.0',
          );
        });

        test('Rating is failure if averageFrameBuildTimeMillis is above 16',
            () {
          when(summary1.averageFrameBuildTimeMillis).thenReturn(20.0);
          when(summary2.averageFrameBuildTimeMillis).thenReturn(20.0);
          final score = performanceScorer.scoreFrameBuildRate(reports);
          expect(score.rating, Rating.failure);
          expect(
            score.infoMessage,
            'The average_frame_build_time_millis of this feature is 20.0',
          );
        });
      });

      group('scoreFrameRasterizerRate', () {
        test(
            'Rating is success if averageFrameRasterizerTimeMillis is below 14',
            () {
          when(summary1.averageFrameRasterizerTimeMillis).thenReturn(2.0);
          when(summary2.averageFrameRasterizerTimeMillis).thenReturn(4.0);
          final score = performanceScorer.scoreFrameRasterizerRate(reports);
          expect(score.rating, Rating.success);
          expect(
            score.infoMessage,
            'Getting 60fps => The average_frame_rasterizer_time_millis of this feature is 3.0',
          );
        });

        test(
            'Rating is warning if averageFrameRasterizerTimeMillis is between 14 and 16',
            () {
          when(summary1.averageFrameRasterizerTimeMillis).thenReturn(15.0);
          when(summary2.averageFrameRasterizerTimeMillis).thenReturn(15.0);
          final score = performanceScorer.scoreFrameRasterizerRate(reports);
          expect(score.rating, Rating.warning);
          expect(
            score.infoMessage,
            'Watch out! This is really close to 16 ms -> The average_frame_rasterizer_time_millis of this feature is 15.0',
          );
        });

        test(
            'Rating is failure if averageFrameRasterizerTimeMillis is above 16',
            () {
          when(summary1.averageFrameRasterizerTimeMillis).thenReturn(20.0);
          when(summary2.averageFrameRasterizerTimeMillis).thenReturn(20.0);
          final score = performanceScorer.scoreFrameRasterizerRate(reports);
          expect(score.rating, Rating.failure);
          expect(
            score.infoMessage,
            'The average_frame_rasterizer_time_millis of this feature is 20.0',
          );
        });
      });
    });

    group('for a single report', () {
      TimelineSummaryReport summary;

      setUp(() {
        summary = MockTimelineSummaryReport();
      });

      group('scoreSummary', () {
        test(
            'gives information about missedFrames, frameBuildRate and frameRasterizerRate',
            () {
          when(summary.frameCount).thenReturn(100);
          when(summary.missedFrameBuildBudgetCount).thenReturn(1);
          when(summary.averageFrameBuildTimeMillis).thenReturn(2.0);
          when(summary.averageFrameRasterizerTimeMillis).thenReturn(2.0);
          final performanceScore = performanceScorer.scoreSummary(summary);
          expect(performanceScore.missedFrames.rating, Rating.success);
          expect(performanceScore.frameBuildRate.rating, Rating.success);
          expect(performanceScore.frameRasterizerRate.rating, Rating.success);
        });
      });

      group('scoreMissedFramesOnSummary', () {
        test('Rating is success if percentage is below 5', () {
          when(summary.frameCount).thenReturn(100);
          when(summary.missedFrameBuildBudgetCount).thenReturn(1);
          final score = performanceScorer.scoreMissedFramesOnSummary(summary);
          expect(score.rating, Rating.success);
          expect(
            score.infoMessage,
            'The percentage of missed frames is 1.0 % (Total: 100, missed: 1)',
          );
        });

        test('Rating is warning if percentage is between 5 and 10', () {
          when(summary.frameCount).thenReturn(100);
          when(summary.missedFrameBuildBudgetCount).thenReturn(8);
          final score = performanceScorer.scoreMissedFramesOnSummary(summary);
          expect(score.rating, Rating.warning);
          expect(
            score.infoMessage,
            'The percentage of missed frames is 8.0 % (Total: 100, missed: 8)',
          );
        });

        test('Rating is success if percentage is above 10', () {
          when(summary.frameCount).thenReturn(100);
          when(summary.missedFrameBuildBudgetCount).thenReturn(20);
          final score = performanceScorer.scoreMissedFramesOnSummary(summary);
          expect(score.rating, Rating.failure);
          expect(
            score.infoMessage,
            'The percentage of missed frames is 20.0 % (Total: 100, missed: 20)',
          );
        });
      });

      group('scoreFrameBuildRateOnSummary', () {
        test('Rating is success if averageFrameBuildTimeMillis is below 14',
            () {
          when(summary.averageFrameBuildTimeMillis).thenReturn(2.0);
          final score = performanceScorer.scoreFrameBuildRateOnSummary(summary);
          expect(score.rating, Rating.success);
          expect(
            score.infoMessage,
            'Getting 60fps => The average_frame_build_time_millis of this feature is 2.0',
          );
        });

        test(
            'Rating is warning if averageFrameBuildTimeMillis is between 14 and 16',
            () {
          when(summary.averageFrameBuildTimeMillis).thenReturn(15.0);
          final score = performanceScorer.scoreFrameBuildRateOnSummary(summary);
          expect(score.rating, Rating.warning);
          expect(
            score.infoMessage,
            'Watch out! This is really close to 16 ms -> The average_frame_build_time_millis of this feature is 15.0',
          );
        });

        test('Rating is failure if averageFrameBuildTimeMillis is above 16',
            () {
          when(summary.averageFrameBuildTimeMillis).thenReturn(20.0);
          final score = performanceScorer.scoreFrameBuildRateOnSummary(summary);
          expect(score.rating, Rating.failure);
          expect(
            score.infoMessage,
            'The average_frame_build_time_millis of this feature is 20.0',
          );
        });
      });

      group('scoreFrameRasterizerRateOnSummary', () {
        test(
            'Rating is success if averageFrameRasterizerTimeMillis is below 14',
            () {
          when(summary.averageFrameRasterizerTimeMillis).thenReturn(2.0);
          final score =
              performanceScorer.scoreFrameRasterizerRateOnSummary(summary);
          expect(score.rating, Rating.success);
          expect(
            score.infoMessage,
            'Getting 60fps => The average_frame_rasterizer_time_millis of this feature is 2.0',
          );
        });

        test(
            'Rating is warning if averageFrameRasterizerTimeMillis is between 14 and 16',
            () {
          when(summary.averageFrameRasterizerTimeMillis).thenReturn(15.0);
          final score =
              performanceScorer.scoreFrameRasterizerRateOnSummary(summary);
          expect(score.rating, Rating.warning);
          expect(
            score.infoMessage,
            'Watch out! This is really close to 16 ms -> The average_frame_rasterizer_time_millis of this feature is 15.0',
          );
        });

        test(
            'Rating is failure if averageFrameRasterizerTimeMillis is above 16',
            () {
          when(summary.averageFrameRasterizerTimeMillis).thenReturn(20.0);
          final score =
              performanceScorer.scoreFrameRasterizerRateOnSummary(summary);
          expect(score.rating, Rating.failure);
          expect(
            score.infoMessage,
            'The average_frame_rasterizer_time_millis of this feature is 20.0',
          );
        });
      });
    });
  });
}
