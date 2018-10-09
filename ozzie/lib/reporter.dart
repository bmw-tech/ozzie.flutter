import 'dart:async';
import 'dart:io';

import 'package:ozzie/html_report.dart';

class Reporter {
  Future generateHtmlReport(String rootFolderName) async {
    final ozzieFiles = await _getOzzieFiles(rootFolderName);
    final imageGallery = _buildImageGallery(ozzieFiles);
    String htmlContent =
        '$beginningOfHtmlReport$imageGallery$endingOfHtmlReport';
    final file = File('$rootFolderName/index.html');
    await file.writeAsString(htmlContent);
  }

  Future<Map<String, List<String>>> _getOzzieFiles(
      String rootFolderName) async {
    final rootDirectory = Directory(rootFolderName);
    final allFiles =
        rootDirectory.listSync(recursive: false, followLinks: false);
    final directories = allFiles
        .where((f) => (f is Directory))
        .map((f) => f as Directory)
        .toList()
          ..sort();
    var ozzieFiles = Map<String, List<String>>();
    directories.forEach((directory) {
      final screenshots = directory
          .listSync(recursive: false, followLinks: false)
          .map((s) => s.path.replaceAll(rootFolderName, ''))
          .toList();
      ozzieFiles[directory.path] = screenshots..sort();
    });
    return ozzieFiles;
  }

  String _buildImageGallery(Map<String, List<String>> ozzieFiles) {
    var accordionBuffer = StringBuffer();
    ozzieFiles.keys.forEach((String entryName) {
      final entry = _buildAccordion(entryName, ozzieFiles[entryName]);
      accordionBuffer.write(entry);
    });
    final accordion = accordionBuffer.toString();

    return """
<div class="accordion" id="ozzieAccordion" style="width: 100%;">
  $accordion
</div>  
    """;
  }

  String _buildAccordion(String accordionName, List<String> images) {
    final randomId = _accordionId(accordionName);
    return """
<div class="card">
  <div class="card-header" id="heading$randomId">
    <h5 class="mb-0">
      <button class="btn btn-link" type="button" data-toggle="collapse" data-target="#collapse$randomId" aria-expanded="true" aria-controls="collapse$randomId">
        $accordionName
      </button>
    </h5>
  </div>
  <div id="collapse$randomId" class="collapse" aria-labelledby="heading$randomId" data-parent="#ozzieAccordion">
    <div class="card-body">
      ${_buildImages(images)}
    </div>
  </div>
</div>
    """;
  }

  String _buildImages(List<String> images) {
    var imageCardsBuffer = StringBuffer();
    images.forEach((imagePath) {
      imageCardsBuffer.write("""
<div class="col-md-3">
  <div class="card mb-3 shadow-sm">
    <img class="card-img-top" style="width: 100%; display: block;" src="./$imagePath" data-holder-rendered="true">
  </div>
</div>
      """);
    });
    final imageCards = imageCardsBuffer.toString();
    return '<div class="row">$imageCards</div>';
  }

  String _accordionId(String accordionName) =>
      '${accordionName.trim().replaceAll(' ', '-').replaceAll('/', '-')}-${accordionName.length}';
}
