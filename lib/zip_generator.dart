import 'dart:io';
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:archive/archive_io.dart';

/// Utility class to generate ZIP files
class ZipGenerator {
  /// It generates a ZIP file with the contents inside [groupFolderName], with
  /// the name `groupName.zip`.
  Future generateZipInFolder({
    @required String groupFolderName,
    @required String groupName,
  }) async {
    final directory = Directory(groupFolderName);
    final zipEncoder = ZipFileEncoder();
    final imageFiles = directory.listSync(recursive: false, followLinks: false);
    zipEncoder.create('$groupFolderName/$groupName.zip');
    imageFiles.forEach((imageFile) => zipEncoder.addFile(imageFile));
    zipEncoder.close();
  }

  /// It generates a ZIP file named `ozzie.zip` with the contents inside the
  /// given [rootFolder]
  Future generateZipWithAllGroups({String rootFolder = 'ozzie'}) async {
    final directory = Directory(rootFolder);
    final zipEncoder = ZipFileEncoder();
    final directories = directory
        .listSync(recursive: false, followLinks: false)
        .where((d) => d is Directory)
        .toList();
    zipEncoder.create('$rootFolder/ozzie.zip');
    directories.forEach((dir) => zipEncoder.addDirectory(dir));
    zipEncoder.close();
  }
}
