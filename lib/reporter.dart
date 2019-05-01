import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:ozzie/html_report.dart';
import 'performance_scorer.dart';
import 'performance_configuration_provider.dart';

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
    final scoreConfiguration = await PerformanceConfigurationProvider.provide();
    final performanceScorer = PerformanceScorer(scoreConfiguration);
    featureDirectories.forEach((featureDirectory) {
      final screenshots = featureDirectory
          .listSync(recursive: false, followLinks: false)
          .map((s) => s.path.replaceAll(rootFolderName, ''))
          .where((s) => s.endsWith('png'))
          .toList();
      final performanceReports = _getPerformanceReportForFeature(
        rootFolderName,
        featureDirectory,
        performanceScorer,
      );
      final score = performanceScorer.score(
        featureDirectory.path,
        performanceReports,
      );
      final report = OzzieReport(
        reportName: featureDirectory.path,
        screenshots: screenshots,
        performanceReports: performanceReports,
        performanceScore: score,
      );
      reports.add(report);
    });
    return reports;
  }

  List<PerformanceReport> _getPerformanceReportForFeature(
    String rootFolderName,
    Directory featureDirectory,
    PerformanceScorer performanceScorer,
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
      final summary = TimelineSummaryReport.fromStringContent(rawContent);
      final report = PerformanceReport(
        testName: _performanceReportTestName(r),
        timelineReport: timelineReports[i],
        timelineSummaryReport: r,
        summaryRawContent: rawContent,
        summaryReportContent: summary,
        score: performanceScorer.scoreSummary(summary),
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
      final entry = _buildAccordion(report);
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
    OzzieReport report,
  ) {
    final randomId = _accordionId(report.reportName);
    return """
<div class="card">
  <div class="card-header" id="heading$randomId">
    <h5 class="mb-0">
      <div class="row justify-content-between">
        <div class="col-3">
          <button class="btn btn-link" type="button" data-toggle="collapse" data-target="#collapse$randomId" aria-expanded="true" aria-controls="collapse$randomId">
            ${_displayName(report.reportName)}
          </button>
        </div>
        <div class="col-9">
          <div class="float-right">
            ${_performanceBadge("Missed Frames", report.performanceScore?.missedFrames?.infoMessage, report.performanceScore?.missedFrames?.rating)}
            ${_performanceBadge("Frame Build Rate", report.performanceScore?.frameBuildRate?.infoMessage, report.performanceScore?.frameBuildRate?.rating)}
            ${_performanceBadge("Frame Rasterizer Rate", report.performanceScore?.frameRasterizerRate?.infoMessage, report.performanceScore?.frameRasterizerRate?.rating)}
            <a href="./${_displayName(report.reportName)}/${_displayName(report.reportName)}.zip" class="btn btn-outline-primary" download>
              Download Images
            </a>
            <button type="button" href="#" class="btn btn-outline-primary" data-toggle="modal" data-target="#${_modalId(report.reportName)}">
              Show Slideshow
            </button>
            ${_buildSlideshow(
      report.screenshots,
      modalId: _modalId(report.reportName),
      modalName: report.reportName,
    )}
          </div>
        </div>
      </div>
    </h5>
  </div>
  <div id="collapse$randomId" class="collapse" aria-labelledby="heading$randomId" data-parent="#ozzieAccordion">
    <div class="card-body">
      ${_buildScreenshotsAndPerformanceTabs(randomId, _buildImages(report.screenshots), _buildPerformanceReport(randomId, report.performanceReports))}
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
  <div class="col-5">
    <div class="nav flex-column nav-pills" id="v-pills-tab" role="tablist" aria-orientation="vertical">
      ${_buildPerformanceReportSideMenu(performanceReports)}
    </div>
  </div>
  <div class="col-7">
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
  <div>
    <span class="badge badge-${_badgeDecorator(performanceReports[index].score.missedFrames.rating)}"><i class="fas fa-crop"></i></span>
    <span class="badge badge-${_badgeDecorator(performanceReports[index].score.frameBuildRate.rating)}"><i class="fas fa-tools"></i></span>
    <span class="badge badge-${_badgeDecorator(performanceReports[index].score.frameRasterizerRate.rating)}"><i class="fas fa-paint-roller"></i></span>
  </div>
</a>
        """);
      } else {
        buffer.write("""
<a class="nav-link" id="v-pills-${performanceReports[index].hashCode}-tab" data-toggle="pill" href="#v-pills-${performanceReports[index].hashCode}" role="tab" aria-controls="v-pills-${performanceReports[index].hashCode}" aria-selected="true">
  ${performanceReports[index].testName} 
  <div>
    <span class="badge badge-${_badgeDecorator(performanceReports[index].score.missedFrames.rating)}"><i class="fas fa-crop"></i></span>
    <span class="badge badge-${_badgeDecorator(performanceReports[index].score.frameBuildRate.rating)}"><i class="fas fa-tools"></i></span>
    <span class="badge badge-${_badgeDecorator(performanceReports[index].score.frameRasterizerRate.rating)}"><i class="fas fa-paint-roller"></i></span>
  </div>
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
  ${_performanceBadge("Missed Frames", performanceReports[index].score?.missedFrames?.infoMessage, performanceReports[index].score?.missedFrames?.rating)}
  ${_performanceBadge("Frame Build Rate", performanceReports[index].score?.frameBuildRate?.infoMessage, performanceReports[index].score?.frameBuildRate?.rating)}
  ${_performanceBadge("Frame Rasterizer Rate", performanceReports[index].score?.frameRasterizerRate?.infoMessage, performanceReports[index].score?.frameRasterizerRate?.rating)}
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

  String _performanceBadge(
    String message,
    String tooltipMessage,
    Rating rating,
  ) {
    return """
<a href="#" class="badge badge-pill badge-${_badgeDecorator(rating)}" data-toggle="tooltip" data-placement="top" title="$tooltipMessage">
  $message
</a>
    """;
  }

  String _badgeDecorator(Rating rating) {
    if (rating == null) return 'secondary';
    if (rating == Rating.success) return 'success';
    if (rating == Rating.warning) return 'warning';
    return 'danger';
  }
}
