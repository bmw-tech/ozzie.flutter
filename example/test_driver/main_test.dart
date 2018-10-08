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
  });

  test('initial counter is 0', () async {
    await ozzie.takeScreenshot('initial_counter_is_0');
  });
}