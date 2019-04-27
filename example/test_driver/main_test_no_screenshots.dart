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
    await ozzie.profilePerformance('counter0', () async {
      await driver.waitFor(find.text('0'));
      await ozzie.takeScreenshot('initial_counter_is_0');
    });
  });

  test('counter is 1', () async {
    await ozzie.profilePerformance('counter1', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('1'));
      await ozzie.takeScreenshot('counter_is_1');
    });
  });

  test('counter is 2', () async {
    await ozzie.profilePerformance('counter2', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('2'));
      await ozzie.takeScreenshot('counter_is_2');
    });
  });

  test('counter is 3', () async {
    await ozzie.profilePerformance('counter3', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('3'));
      await ozzie.takeScreenshot('counter_is_3');
    });
  });

  test('counter is 4', () async {
    await ozzie.profilePerformance('counter4', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('4'));
      await ozzie.takeScreenshot('counter_is_4');
    });
  });

  test('counter is 5', () async {
    await ozzie.profilePerformance('counter5', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('5'));
      await ozzie.takeScreenshot('counter_is_5');
    });
  });

  test('counter is 6', () async {
    await ozzie.profilePerformance('counter6', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('6'));
      await ozzie.takeScreenshot('counter_is_6');
    });
  });

  test('counter is 7', () async {
    await ozzie.profilePerformance('counter7', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('7'));
      await ozzie.takeScreenshot('counter_is_7');
    });
  });

  test('counter is 8', () async {
    await ozzie.profilePerformance('counter8', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('8'));
      await ozzie.takeScreenshot('counter_is_8');
    });
  });

  test('counter is 9', () async {
    await ozzie.profilePerformance('counter9', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('9'));
      await ozzie.takeScreenshot('counter_is_9');
    });
  });

  test('counter is 10', () async {
    await ozzie.profilePerformance('counter10', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('10'));
      await ozzie.takeScreenshot('counter_is_10');
    });
  });

  test('counter is 11', () async {
    await ozzie.profilePerformance('counter11', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('11'));
      await ozzie.takeScreenshot('counter_is_11');
    });
  });

  test('counter is 12', () async {
    await ozzie.profilePerformance('counter12', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('12'));
      await ozzie.takeScreenshot('counter_is_12');
    });
  });

  test('counter is 13', () async {
    await ozzie.profilePerformance('counter13', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('13'));
      await ozzie.takeScreenshot('counter_is_13');
    });
  });

  test('counter is 14', () async {
    await ozzie.profilePerformance('counter14', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('14'));
      await ozzie.takeScreenshot('counter_is_14');
    });
  });

  test('counter is 15', () async {
    await ozzie.profilePerformance('counter15', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('15'));
      await ozzie.takeScreenshot('counter_is_15');
    });
  });

  test('counter is 16', () async {
    await ozzie.profilePerformance('counter16', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('16'));
      await ozzie.takeScreenshot('counter_is_16');
    });
  });

  test('counter is 17', () async {
    await ozzie.profilePerformance('counter17', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('17'));
      await ozzie.takeScreenshot('counter_is_17');
    });
  });

  test('counter is 18', () async {
    await ozzie.profilePerformance('counter18', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('18'));
      await ozzie.takeScreenshot('counter_is_18');
    });
  });

  test('counter is 19', () async {
    await ozzie.profilePerformance('counter19', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('19'));
      await ozzie.takeScreenshot('counter_is_19');
    });
  });

  test('counter is 20', () async {
    await ozzie.profilePerformance('counter20', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('20'));
      await ozzie.takeScreenshot('counter_is_20');
    });
  });
}
