library ozzie;

import 'dart:async';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'reporter.dart';

const rootFolderName = "ozzie";

class Ozzie {
  final FlutterDriver driver;
  final String groupName;
  var _doesGroupFolderNeedToBeDeleted = true;

  Ozzie._internal(this.driver, {this.groupName = "default"})
      : assert(driver != null);

  factory Ozzie.initWith(FlutterDriver driver, {@required String groupName}) =>
      Ozzie._internal(driver, groupName: groupName);

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
