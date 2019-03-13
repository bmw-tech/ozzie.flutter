library ozzie;

import 'dart:async';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'reporter.dart';
import 'zip_generator.dart';

const rootFolderName = "ozzie";

/// [Ozzie] is the class responsible for taking screenshots and generating
/// an HTML report when running your integrationt tests on Flutter.
class Ozzie {
  final FlutterDriver driver;
  final String groupName;
  final bool shouldTakeScreenshots;
  var _doesGroupFolderNeedToBeDeleted = true;

  Ozzie._internal(
    this.driver, {
    @required this.groupName,
    @required this.shouldTakeScreenshots,
  }) : assert(driver != null);

  /// Build an [Ozzie] object with the given [FlutterDriver]. If a `groupName`
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
  factory Ozzie.initWith(
    FlutterDriver driver, {
    String groupName = "default",
    bool shouldTakeScreenshots = true,
  }) =>
      Ozzie._internal(
        driver,
        groupName: groupName,
        shouldTakeScreenshots: shouldTakeScreenshots,
      );

  /// It takes a an PNG screnshot of the given state of the application when
  /// being called. The name of the screenshot will be the given `screenshotName`
  /// prefixed by the timestamp of that moment, and suffixed by `.png`.
  /// It will be stored in a folder whose name will be the given `groupName`
  /// when calling `Ozzie.initWith`.
  Future takeScreenshot(String screenshotName) async {
    if (shouldTakeScreenshots) {
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
  }

  /// This is the method that will generate the HTML report with all the
  /// screenshots taken during integration tests.
  /// This is method is intended to be called in your tests `tearDown`,
  /// immediately after closing the given [FlutterDriver].
  Future generateHtmlReport() async {
    if (shouldTakeScreenshots) {
      await _generateZipFiles();
      final reporter = Reporter();
      await reporter.generateHtmlReport(
        rootFolderName: rootFolderName,
        groupName: groupName,
      );
    } else {
      print('Ozzie - No screenshots taken.');
    }
  }

  Future _generateZipFiles() async {
    final zipGenerator = ZipGenerator();
    await zipGenerator.generateZipWithAllGroups();
    await zipGenerator.generateZipInFolder(
      groupFolderName: _groupFolderName,
      groupName: groupName,
    );
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
