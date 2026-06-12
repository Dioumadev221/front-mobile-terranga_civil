import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Mobile/desktop : écrit le PDF dans le dossier documents de l'app.
Future<String> savePdf(List<int> bytes, String filename) async {
  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/$filename';
  await File(path).writeAsBytes(bytes, flush: true);
  return path;
}
