import 'dart:async';
import 'dart:io';

class Reporter {
  Future<Map<String, List<String>>> getOzzieFiles(String rootFolderName) async {
    final rootDirectory = Directory(rootFolderName);
    final allFiles =
        rootDirectory.listSync(recursive: false, followLinks: false);
    final directories =
        allFiles.where((f) => (f is Directory)).map((f) => f as Directory);
    var ozzieFiles = Map();
    directories.forEach((directory) {
      final screenshots = directory
          .listSync(recursive: false, followLinks: false)
          .map((s) => s.path);
      ozzieFiles[directory.path] = screenshots;
    });
    return ozzieFiles;
  }
}
