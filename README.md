# ozzie.flutter

[![Build Status](https://travis-ci.com/jorgecoca/ozzie.flutter.svg?branch=master)](https://travis-ci.com/jorgecoca/ozzie.flutter)
[![codecov](https://codecov.io/gh/jorgecoca/ozzie.flutter/branch/master/graph/badge.svg)](https://codecov.io/gh/jorgecoca/ozzie.flutter)
[![Pub](https://img.shields.io/pub/v/ozzie.svg)](https://pub.dartlang.org/packages/ozzie)

![ozzie icon art](./art/ozzie.png)

Ozzie is your testing friend. Ozzie will take an screenshot during integration tests whenever you need. Ozzie will capture performance reports for you.

## How it works

Add `ozzie` to your `pubspec.yaml` as a **dev_dependency**:

```yaml
dev_dependencies:
  ozzie: <latest_version_here>
```

In your Flutter integration tests, create an instance of `Ozzie`, pass the `FlutterDriver`, give it a `groupName` and ask it to `takeScreenshot`. That simple! And whenever you have finished with tests, you can create an HTML report by asking `Ozzie` to `generateHtmlReport`.

If you want to measure the performance of your app, simple wrap your integration tests in `profilePerformance` and it will be added to the HTML report.

Here's an example:

```dart
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
    ozzie.generateHtmlReport();
  });

  test('initial counter is 0', () async {
    await ozzie.profilePerformance('counter0', () async {
      await driver.waitFor(find.text('0'));
      await ozzie.takeScreenshot('initial_counter_is_0');
    });
  });

  test('initial counter is 0', () async {
    await ozzie.profilePerformance('counter1', () async {
      await driver.tap(find.byType('FloatingActionButton'));
      await driver.waitFor(find.text('1'));
      await ozzie.takeScreenshot('counter_is_1');
    });
  });
}
```

After this, a report will be generated inside your project as `ozzie/index.html`:

![report example](./art/report.gif)

### Optional screenshots

Taking screenshots can take a while, and sometimes you might want to run your integration tests without taking screenshots. If that's the case, you can set `shouldTakeScreenshots` to `false` and skip that part, saving you some precious time:

```dart
setUpAll(() async {
  driver = await FlutterDriver.connect();
  ozzie = Ozzie.initWith(
    driver,
    groupName: 'counter',
    shouldTakeScreenshots: false,
  );
});
```

## License

```
Copyright 2018 Jorge Coca

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
