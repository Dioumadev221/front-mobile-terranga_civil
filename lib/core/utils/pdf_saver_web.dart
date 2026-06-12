// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web : crée un Blob PDF et déclenche le téléchargement via un lien <a>.
Future<String> savePdf(List<int> bytes, String filename) async {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none'
    ..click();
  html.Url.revokeObjectUrl(url);
  return filename;
}
