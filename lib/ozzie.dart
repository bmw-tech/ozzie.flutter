library ozzie;

import 'dart:async';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'reporter.dart';

const rootFolderName = "ozzie";

/// [Ozzie] is the class responsible for taking screenshots and generating 
/// an HTML report when running your integrationt tests on Flutter.
class Ozzie {
  final FlutterDriver driver;
  final String groupName;
  var _doesGroupFolderNeedToBeDeleted = true;

  Ozzie._internal(this.driver, {this.groupName = "default"})
      : assert(driver != null);

  /// Build and [Ozzie] object with the given [FlutterDriver]. If a `groupName`
  /// is given, it will be used to group your screenshots in the HTML report; 
  /// otherwise, they will be placed under a "default" group.
  /// This method is intended to be called in your tests `setUp`, immediately
  /// after a [FlutterDriver] object has been built.
  /// 
  /// Usage:
  /// 
  /// ```
  /// Ozzie.initWith(driver) -> will group the screenshots taken under "default"
  /// Ozzie.initWith(driver, 'my_report') -> will group the screenshots taken under "my_report"
  /// ```
  factory Ozzie.initWith(FlutterDriver driver, {@required String groupName}) =>
      Ozzie._internal(driver, groupName: groupName);

  /// It takes a an PNG screnshot of the given state of the application when 
  /// being called. The name of the screenshot will be the given `screenshotName`
  /// prefixed by the time stamp of that moment, and suffixed by `.png`.
  /// It will be stored in a folder whose name will be the given `groupName`
  /// when calling `Ozzie.initWith`.
  Future takeScreenshot(String screenshotName) async {
    if (_doesGroupFolderNeedToBeDeleted) {
      await _deleteExistingGroupFolder();
      _doesGroupFolderNeedToBeDeleted = false;
    }
    final filePath = _filePath(screenshotName);
    final file = await File(filePath).create(recursive: true);
    final pixels = await driver.screenshot();
    await file.writeAsBytes(pixels);
    print('Ozzie took screenshot: $filePath');
  }

  /// This is the method that will generate the HTML report with all the
  /// screenshots taken during integration tests.
  /// This is method is intended to be called in your tests `tearDown`,
  /// immediately after closing the given [FlutterDriver].
  Future generateHtmlReport() async {
    final reporter = Reporter();
    await reporter.generateHtmlReport(rootFolderName);
  }

  Future _deleteExistingGroupFolder() async {
    final groupFolder = Directory(_groupFolderName);
    if (await groupFolder.exists()) {
      await groupFolder.delete(recursive: true);
      print('Ozzie has deleted the "$groupName" folder');
    }
  }

  String get _groupFolderName => '$rootFolderName/$groupName';

  String get _timestamp => DateTime.now().toIso8601String();

  String _fileName(String screenshotName) => '$_timestamp-$screenshotName.png';

  String _filePath(String screenshotName) {
    final fileName = _fileName(screenshotName);
    return '$_groupFolderName/$fileName';
  }
}
