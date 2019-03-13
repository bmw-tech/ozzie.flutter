import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:ozzie/ozzie.dart';

void main() {
  FlutterDriver driver;
  Ozzie ozzie;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
    ozzie = Ozzie.initWith(
      driver,
      groupName: 'counter',
      shouldTakeScreenshots: false,
    );
  });

  tearDownAll(() async {
    if (driver != null) await driver.close();
    await ozzie.generateHtmlReport();
  });

  test('initial counter is 0', () async {
    await ozzie.takeScreenshot('initial_counter_is_0');
  });

  test('counter is 1', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_1');
  });

  test('counter is 2', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_2');
  });

  test('counter is 3', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_3');
  });

  test('counter is 4', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_4');
  });

  test('counter is 5', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_5');
  });

  test('counter is 6', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_6');
  });

  test('counter is 7', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_7');
  });

  test('counter is 8', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_8');
  });

  test('counter is 9', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_9');
  });

  test('counter is 10', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_10');
  });

  test('counter is 11', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_11');
  });

  test('counter is 12', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_12');
  });

  test('counter is 13', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_13');
  });

  test('counter is 14', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_14');
  });

  test('counter is 15', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_15');
  });

  test('counter is 16', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_16');
  });

  test('counter is 17', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_17');
  });

  test('counter is 18', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_18');
  });

  test('counter is 19', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_19');
  });

  test('counter is 20', () async {
    await driver.tap(find.byType('FloatingActionButton'));
    await ozzie.takeScreenshot('counter_is_20');
  });
}
