library ozzie;

import 'dart:io';
import 'package:meta/meta.dart';
import 'package:flutter_driver/flutter_driver.dart';

const _rootFolderName = "ozzie";

class Ozzie {
  final FlutterDriver driver;
  final String groupName;

  const Ozzie._internal(this.driver, {this.groupName = "default"})
      : assert(driver != null);

  factory Ozzie.initWith(
          {@required FlutterDriver driver, @required String groupName}) =>
      Ozzie._internal(driver, groupName: groupName);

  void takeScreenshot(String screenshotName) async {
    if (driver == null)
      throw ArgumentError('FlutterDriver is null. Did you initialize it?');
    _deleteExistingGroupFolder();
    final file = await File(_filePath(screenshotName)).create(recursive: true);
    final pixels = await driver.screenshot();
    file.writeAsBytes(pixels);
  }

  void _deleteExistingGroupFolder() async {
    final groupFolder = File(_groupFolderName);
    if (await groupFolder.exists()) groupFolder.delete(recursive: true);
  }

  String get _groupFolderName => '$_rootFolderName/$groupName';

  String _timestamp() => DateTime.now().toString();

  String _fileName(String screenshotName) => '$_timestamp-$screenshotName.png';

  String _filePath(String screenshotName) =>
      '$_groupFolderName/$_fileName(screenshotName)';
}
