import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:ozzie/ozzie.dart';

void main() {
  FlutterDriver driver;
  Ozzie ozzie;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
    ozzie = Ozzie.initWith(driver, groupName: 'counter');
  });

  tearDownAll(() async {
    if (driver != null) driver.close();
    await ozzie.generateHtmlReport();
  });

  test('initial counter is 0', () async {
    await ozzie.takeScreenshot('initial_counter_is_0');
  });

  test('initial counter is 0', () async {
    driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_1');
  });
}