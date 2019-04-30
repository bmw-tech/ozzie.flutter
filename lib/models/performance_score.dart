import 'package:meta/meta.dart';

/// - Use success if everything looks good
/// - Use warning if you want to raise the severity level, but it is
/// not an error yet
/// - Use failure if the value is not acceptable
enum Rating { success, warning, failure }

/// Model that represents how well a feature is performing
class Score {
  final Rating rating;
  final String infoMessage;

  Score(this.rating, this.infoMessage);

  @override
  String toString() => 'Score { rating: $rating, infoMessage: $infoMessage }';
}

/// Model that encapsulates the scoring values of a feature
class PerformanceScore {
  final Score missedFrames;
  final Score frameBuildRate;
  final Score frameRasterizerRate;

  PerformanceScore({
    @required this.missedFrames,
    @required this.frameBuildRate,
    @required this.frameRasterizerRate,
  });
}
