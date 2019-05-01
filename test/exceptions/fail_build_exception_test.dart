import 'package:test/test.dart';
import 'package:ozzie/exceptions/exceptions.dart';

void main() {
  group('FailBuildException', () {
    test('onWarning message is properly formatted', () {
      final e = FailBuildException.onWarning('test123');
      final expectedMessage = """
¯\_(ツ)_/¯  Warnign detected

Ozzie has measured warnings on the test123 feature, and your configuration
suggests that performance tests with warnigns should fail the build.
    
Check your configuration at ozzie.yaml in case you want to make adjustments.
  """;
      expect(e.message, expectedMessage);
    });

    test('onError message is properly formatted', () {
      final e = FailBuildException.onError('test123');
      final expectedMessage = """
(╯°□°)╯︵ ɹoɹɹƎ Detected

Ozzie has measured errors on the test123 feature, and your configuration
suggests that performance tests with failures should fail the build.
    
Check your configuration at ozzie.yaml in case you want to make adjustments.
  """;
      expect(e.message, expectedMessage);
    });

    test('toString message is properly formatted', () {
      final e = FailBuildException.onError('test123').toString();
      final expectedMessage = """FailBuildException: 
(╯°□°)╯︵ ɹoɹɹƎ Detected

Ozzie has measured errors on the test123 feature, and your configuration
suggests that performance tests with failures should fail the build.
    
Check your configuration at ozzie.yaml in case you want to make adjustments.
  """;
      expect(e, expectedMessage);
    });
  });
}
