import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/widgets/upload_document_card.dart'
    show DocumentUploadHelper;

class NaissanceRemoteDatasource {
  final DioClient client;
  const NaissanceRemoteDatasource({required this.client});

  /// Envoie la **vraie** image au backend OCR (`/ai/ocr/extract/`) en multipart
  /// et retourne les données extraites, normalisées vers les clés attendues par
  /// l'écran (`date_naissance` au format ISO, etc.).
  ///
  /// NOTE : l'OCR backend actuel analyse des **CNI** (`nom`, `prenom`,
  /// `date_naissance` en `jj/mm/aaaa`, `lieu_naissance`...). Il ne sait pas
  /// encore lire un extrait de naissance, donc `registre` / `annee_registre` /
  /// `commune_*` ne reviennent pas tant que le backend n'ajoute pas un parseur
  /// d'extrait. Seule la date de naissance est réellement exploitable ici ;
  /// le reste reste à saisir manuellement.
  Future<Map<String, dynamic>> extractOcr(String imagePath) async {
    try {
      final fileName = imagePath.split(RegExp(r'[\\/]')).last;
      final bytes = DocumentUploadHelper.bytesFor(imagePath);
      final MultipartFile multipart = bytes != null
          ? MultipartFile.fromBytes(bytes, filename: fileName)
          : await MultipartFile.fromFile(imagePath, filename: fileName);

      // NB : on n'envoie PAS `dossier_type`. Le backend déclenche une
      // vérification de doublon de dossier si ce champ est présent, et renvoie
      // 400 dès que le citoyen a déjà un dossier naissance en cours — alors
      // que l'OCR ne fait que lire une image (aucun dossier créé ici).
      final formData = FormData.fromMap({
        'document': multipart,
      });

      final res = await client.post('/ai/ocr/extract/', data: formData);

      if (res.statusCode == 200 && res.data is Map) {
        final body = res.data as Map<String, dynamic>;
        final extracted =
            (body['extracted_data'] as Map?)?.cast<String, dynamic>() ?? {};
        return _normalize(extracted);
      }
      throw const ApiException(message: 'Extraction OCR échouée');
    } on DioException {
      throw const ApiException(message: 'Erreur lors de l\'extraction OCR');
    }
  }

  /// Convertit les champs CNI renvoyés par le backend vers les clés que l'écran
  /// sait consommer. Aujourd'hui seule `date_naissance` est traduisible
  /// (`jj/mm/aaaa` → `aaaa-mm-jj`).
  Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
    final out = <String, dynamic>{};
    final dob = (raw['date_naissance'] as String?)?.trim() ?? '';
    final iso = _toIsoDate(dob);
    if (iso != null) out['date_naissance'] = iso;
    return out;
  }

  /// `jj/mm/aaaa` → `aaaa-mm-jj` (null si le format est inattendu).
  String? _toIsoDate(String value) {
    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(value);
    if (m == null) return null;
    return '${m.group(3)}-${m.group(2)}-${m.group(1)}';
  }
}
