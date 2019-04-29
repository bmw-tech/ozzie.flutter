import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:ozzie/html_report.dart';

import 'models/models.dart';

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
    final ozzieFiles = await _getOzzieReports(rootFolderName);
    final imageGallery = _buildOzzieReport(ozzieFiles);
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

  Future<List<OzzieReport>> _getOzzieReports(
    String rootFolderName,
  ) async {
    final rootDirectory = Directory(rootFolderName);
    final allFiles =
        rootDirectory.listSync(recursive: false, followLinks: false);
    final featureDirectories = allFiles
        .where((f) => (f is Directory))
        .map((f) => f as Directory)
        .toList();
    var reports = List<OzzieReport>();
    featureDirectories.forEach((featureDirectory) {
      final screenshots = featureDirectory
          .listSync(recursive: false, followLinks: false)
          .map((s) => s.path.replaceAll(rootFolderName, ''))
          .where((s) => s.endsWith('png'))
          .toList();
      final performanceReports = _getPerformanceReportForFeature(
        rootFolderName,
        featureDirectory,
      );
      final report = OzzieReport(
        reportName: featureDirectory.path,
        screenshots: screenshots,
        performanceReports: performanceReports,
      );
      reports.add(report);
    });
    return reports;
  }

  List<PerformanceReport> _getPerformanceReportForFeature(
    String rootFolderName,
    Directory featureDirectory,
  ) {
    final profileDirectories = featureDirectory
        .listSync(recursive: false, followLinks: false)
        .where((d) => d is Directory)
        .where((d) => d.path.contains('profiling'))
        .map((d) => d as Directory);
    if (profileDirectories == null || profileDirectories.isEmpty) return [];
    var reports = List<PerformanceReport>();
    final profileContents = profileDirectories.first
        .listSync(recursive: false, followLinks: false)
        .map((s) => s.path.replaceAll(rootFolderName, ''));
    final timelineReports =
        profileContents.where((s) => s.endsWith('timeline.json')).toList();
    final summaryReports = profileContents
        .where((s) => s.endsWith('timeline_summary.json'))
        .toList();
    assert(timelineReports.length == summaryReports.length);
    summaryReports.asMap().forEach((i, r) {
      final rawContent = _readFileContents(rootFolderName, r);
      final report = PerformanceReport(
        testName: _performanceReportTestName(r),
        timelineReport: timelineReports[i],
        timelineSummaryReport: r,
        summaryRawContent: rawContent,
        summaryReportContent: TimelineSummaryReport.fromStringContent(
          rawContent,
        ),
      );
      reports.add(report);
    });
    return reports;
  }

  String _buildOzzieReport(
    List<OzzieReport> ozzieReports,
  ) {
    var accordionBuffer = StringBuffer();
    ozzieReports.forEach((report) {
      final entry = _buildAccordion(
        report.reportName,
        report.screenshots,
        report.performanceReports,
      );
      accordionBuffer.write(entry);
    });
    final accordion = accordionBuffer.toString();

    return """
<div class="accordion" id="ozzieAccordion" style="width: 100%;">
  $accordion
</div>  
    """;
  }

  String _buildAccordion(
    String accordionName,
    List<String> screenshots,
    List<PerformanceReport> performanceReports,
  ) {
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
      screenshots,
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
      ${_buildScreenshotsAndPerformanceTabs(randomId, _buildImages(screenshots), _buildPerformanceReport(randomId, performanceReports))}
    </div>
  </div>
</div>
    """;
  }

  String _buildScreenshotsAndPerformanceTabs(String accordionId,
      String screenshotsHtmlSnippet, String performanceHtmlSnippet) {
    return """
<nav>
  <div class="nav nav-tabs" id="nav-tab" role="tablist">
    <a class="nav-item nav-link active" id="nav-screenshots-$accordionId-tab" data-toggle="tab" href="#nav-screenshots-$accordionId" role="tab" aria-controls="nav-screenshots-$accordionId" aria-selected="true">Screenshots</a>
    <a class="nav-item nav-link" id="nav-performance-$accordionId-tab" data-toggle="tab" href="#nav-performance-$accordionId" role="tab" aria-controls="nav-performance-$accordionId" aria-selected="false">Performance</a>
  </div>
</nav>
<div class="tab-content" id="nav-tabContent">
  <div class="tab-pane fade show active" id="nav-screenshots-$accordionId" role="tabpanel" aria-labelledby="nav-screenshots-$accordionId-tab">
    <p>
      $screenshotsHtmlSnippet
    </p>
  </div>
  <div class="tab-pane fade" id="nav-performance-$accordionId" role="tabpanel" aria-labelledby="nav-performance-$accordionId-tab">
    <p>
      $performanceHtmlSnippet
    </p>
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

  String _buildPerformanceReport(
      String accordionId, List<PerformanceReport> performanceReports) {
    return """
<div class="row">
  <div class="col-4">
    <div class="nav flex-column nav-pills" id="v-pills-tab" role="tablist" aria-orientation="vertical">
      ${_buildPerformanceReportSideMenu(performanceReports)}
    </div>
  </div>
  <div class="col-8">
    <div class="tab-content" id="v-pills-tabContent">
      ${_buildPerformanceReportContent(performanceReports)}
    </div>
  </div>
</div>
    """;
  }

  String _buildPerformanceReportSideMenu(
    List<PerformanceReport> performanceReports,
  ) {
    final buffer = StringBuffer();
    for (var index = 0; index < performanceReports.length; index++) {
      if (index == 0) {
        buffer.write("""
<a class="nav-link active" id="v-pills-${performanceReports[index].hashCode}-tab" data-toggle="pill" href="#v-pills-${performanceReports[index].hashCode}" role="tab" aria-controls="v-pills-${performanceReports[index].hashCode}" aria-selected="true">
  ${performanceReports[index].testName}
</a>
        """);
      } else {
        buffer.write("""
<a class="nav-link" id="v-pills-${performanceReports[index].hashCode}-tab" data-toggle="pill" href="#v-pills-${performanceReports[index].hashCode}" role="tab" aria-controls="v-pills-${performanceReports[index].hashCode}" aria-selected="true">
  ${performanceReports[index].testName}
</a>
        """);
      }
    }
    return buffer.toString();
  }

  String _buildPerformanceReportContent(
    List<PerformanceReport> performanceReports,
  ) {
    final buffer = StringBuffer();
    for (var index = 0; index < performanceReports.length; index++) {
      final content = """
<p>
  <a href="./${performanceReports[index].timelineSummaryReport}" class="btn btn-outline-primary btn-sm" role="button" aria-pressed="true" download>Download Summary Report</a>
  <a href="./${performanceReports[index].timelineReport}" class="btn btn-outline-info btn-sm" role="button" aria-pressed="true" download>Download Timeline Report</a>
</p>
<p>
  <pre>
    <code>
      ${performanceReports[index].summaryRawContent}
    </code>
  </pre>
</p>
      """;
      if (index == 0) {
        buffer.write("""
<div class="tab-pane fade show active" id="v-pills-${performanceReports[index].hashCode}" role="tabpanel" aria-labelledby="v-pills-${performanceReports[index].hashCode}-tab">
  $content
</div>
        """);
      } else {
        buffer.write("""
<div class="tab-pane fade show" id="v-pills-${performanceReports[index].hashCode}" role="tabpanel" aria-labelledby="v-pills-${performanceReports[index].hashCode}-tab">
  $content
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

  String _performanceReportTestName(String summaryFileName) => summaryFileName
      .replaceAll('.timeline_summary.json', '')
      .replaceAll('profiling/', '');

  String _readFileContents(String rootFolderName, String relativePath) {
    final file = File('$rootFolderName/$relativePath');
    return file.readAsStringSync();
  }
}
