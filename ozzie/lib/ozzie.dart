library ozzie;

import 'dart:async';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:flutter_driver/flutter_driver.dart';

const _rootFolderName = "ozzie";

class Ozzie {
  final FlutterDriver driver;
  final String groupName;

  const Ozzie._internal(this.driver, {this.groupName = "default"})
      : assert(driver != null);

  factory Ozzie.initWith(FlutterDriver driver, {@required String groupName}) =>
      Ozzie._internal(driver, groupName: groupName);

  Future takeScreenshot(String screenshotName) async {
    if (driver == null)
      throw ArgumentError('FlutterDriver is null. Did you initialize it?');
    await _deleteExistingGroupFolder();
    final file = await File(_filePath(screenshotName)).create(recursive: true);
    final pixels = await driver.screenshot();
    await file.writeAsBytes(pixels);
  }

  Future _deleteExistingGroupFolder() async {
    final groupFolder = Directory(_groupFolderName);
    if (await groupFolder.exists()) await groupFolder.delete(recursive: true);  
  }

  String get _groupFolderName => '$_rootFolderName/$groupName';

  String get _timestamp => DateTime.now().toIso8601String();

  String _fileName(String screenshotName) => '$_timestamp-$screenshotName.png';

  String _filePath(String screenshotName) {
    final fileName = _fileName(screenshotName);
    return '$_groupFolderName/$fileName';
  }
}
