/// Exception thrown when Ozzie fails a set of integration tests
class FailBuildException implements Exception {
  String message;

  FailBuildException(this.message);

  /// Helper to build an exception based on warnings in the report
  factory FailBuildException.onWarning(String featureName) {
    return FailBuildException("""
¯\_(ツ)_/¯  Warning detected

Ozzie has detected warnings on the $featureName feature, and your configuration
suggests that performance tests with warnings should fail the build.
    
Check your configuration at ozzie.yaml in case you want to make adjustments.
  """);
  }

  /// Helper to build an exception based on errors in the report
  factory FailBuildException.onError(String featureName) {
    return FailBuildException("""
(╯°□°)╯︵ ɹoɹɹƎ Detected

Ozzie has detected errors on the $featureName feature, and your configuration
suggests that performance tests with failures should fail the build.
    
Check your configuration at ozzie.yaml in case you want to make adjustments.
  """);
  }

  @override
  String toString() => 'FailBuildException: \n${this.message}';
}
