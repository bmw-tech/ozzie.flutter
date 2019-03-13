import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:ozzie/html_report.dart';

/// [Reporter] is the class in charge of actually generating the HTML report.
class Reporter {
  /// This method is what generates the HTML report with the given
  /// `rootFolderName`.
  /// It should only be called after all the screnshots have been taken,
  /// so the reporter can inspect the given `rootFolderName` and generate
  /// the proper HTML code. That's why, calling this method from
  /// `Ozzie.generateHtmlReport` is ideal.
  /// The `groupName` is necessary to generate the ZIP files included in
  /// the HTML report.
  Future generateHtmlReport({
    @required String rootFolderName,
    @required String groupName,
  }) async {
    final ozzieFiles = await _getOzzieFiles(rootFolderName);
    final imageGallery = _buildImageGallery(ozzieFiles);
    String htmlContent =
        '$beginningOfHtmlReport$imageGallery$endingOfHtmlReport';
    final filePath = '$rootFolderName/index.html';
    final file = File(filePath);
    await file.writeAsString(htmlContent);
    print(""" 
         _ 
     _n_|_|_,_
    |===.-.===|
    |  ((_))  |
    '==='-'==='  
    """);
    print('Ozzie has generated the HTML at: $filePath');
  }

  Future<Map<String, List<String>>> _getOzzieFiles(
    String rootFolderName,
  ) async {
    final rootDirectory = Directory(rootFolderName);
    final allFiles =
        rootDirectory.listSync(recursive: false, followLinks: false);
    final directories = allFiles
        .where((f) => (f is Directory))
        .map((f) => f as Directory)
        .toList();
    var ozzieFiles = Map<String, List<String>>();
    directories.forEach((directory) {
      final screenshots = directory
          .listSync(recursive: false, followLinks: false)
          .map((s) => s.path.replaceAll(rootFolderName, ''))
          .where((s) => s.endsWith('png'))
          .toList();
      ozzieFiles[directory.path] = screenshots..sort();
    });
    return ozzieFiles;
  }

  String _buildImageGallery(
    Map<String, List<String>> ozzieFiles,
  ) {
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
      <div class="row justify-content-between">
        <div class="col-4">
          <button class="btn btn-link" type="button" data-toggle="collapse" data-target="#collapse$randomId" aria-expanded="true" aria-controls="collapse$randomId">
            ${_displayName(accordionName)}
          </button>
        </div>
        <div class="col-8">
          <div class="float-right">
            <a href="./${_displayName(accordionName)}/${_displayName(accordionName)}.zip" class="btn btn-outline-primary" download>
              Download Images
            </a>
            <button type="button" href="#" class="btn btn-outline-primary" data-toggle="modal" data-target="#${_modalId(accordionName)}">
              Show Slideshow
            </button>
            ${_buildSlideshow(
      images,
      modalId: _modalId(accordionName),
      modalName: accordionName,
    )}
          </div>
        </div>
      </div>
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
    <div card="card-body">
      <p class="card-text">$imagePath</p>
    </div>
  </div>
</div>
      """);
    });
    final imageCards = imageCardsBuffer.toString();
    return '<div class="row">$imageCards</div>';
  }

  String _buildSlideshow(
    List<String> images, {
    @required String modalId,
    @required String modalName,
  }) {
    return """
<div class="modal fade" id="$modalId" tabIndex="-1" role="dialog" aria-labelledby="${modalId}Label" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="${modalId}Label">$modalName</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <div id="carouselExampleControls" class="carousel slide carousel-fade" data-ride="carousel" data-interval="2000">
          <div class="carousel-inner">
            ${_buildCarousel(images)}
          </div>
          <a class="carousel-control-prev" href="#carouselExampleControls" role="button" data-slide="prev">
            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
            <span class="sr-only">Previous</span>
          </a>
          <a class="carousel-control-next" href="#carouselExampleControls" role="button" data-slide="next">
            <span class="carousel-control-next-icon" aria-hidden="true"></span>
            <span class="sr-only">Next</span>
          </a>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>
""";
  }

  String _buildCarousel(List<String> images) {
    final buffer = StringBuffer();
    for (var index = 0; index < images.length; index++) {
      if (index == 0) {
        buffer.write("""
<div class="carousel-item active">
  <img src="./${images[index]}" class="d-block w-100" alt="${images[index]}">
</div>
""");
      } else {
        buffer.write("""
<div class="carousel-item">
  <img src="./${images[index]}" class="d-block w-100" alt="${images[index]}">
</div>
""");
      }
    }
    return buffer.toString();
  }

  String _accordionId(String accordionName) =>
      '${accordionName.trim().replaceAll(' ', '_').replaceAll('/', '_')}${accordionName.length}';

  String _modalId(String accordionName) =>
      "${_displayName(accordionName)}Modal";

  String _displayName(String ozzieFile) => ozzieFile.replaceAll('ozzie/', '');
}
