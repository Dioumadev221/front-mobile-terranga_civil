import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/mock/mock_config.dart';
import '../../../core/mock/mock_service.dart';
import 'models/dossier_model.dart';

class DossiersRemoteDatasource {
  final DioClient client;
  const DossiersRemoteDatasource({required this.client});

  Future<List<DossierModel>> getDossiers() async {
    final res = await client.get('/dossiers/');
    if (res.statusCode == 200 && res.data != null) {
      final body = res.data;
      // Réponse paginée standard : {success, message, data: {results: [...]}, errors}
      final data = (body is Map<String, dynamic>) ? body['data'] : null;
      final list = (data is Map<String, dynamic>) ? data['results'] : body;
      if (list is List) {
        return list
            .map((e) => DossierModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    throw const ApiException(message: 'Impossible de charger les dossiers');
  }

  Future<DossierModel> getDossierById(String id) async {
    final res = await client.get('/dossiers/$id/');
    if (res.statusCode == 200 && res.data != null) {
      final body = res.data;
      final inner = (body is Map<String, dynamic>) ? body['data'] : null;
      if (inner is Map<String, dynamic>) {
        return DossierModel.fromJson(inner);
      }
      if (body is Map<String, dynamic>) {
        return DossierModel.fromJson(body);
      }
    }
    throw const NotFoundException();
  }

  /// Crée un dossier (brouillon) puis le soumet immédiatement.
  ///
  /// [payload] est construit par les providers de certificats
  /// (naissance/mariage/décès) avec les clés :
  /// - `type` : code UI français (`naissance`, `mariage`, `deces`, ...)
  /// - `commune_id` : identifiant de la commune (UUID backend)
  /// - `beneficiary` : informations bénéficiaire (Map) — historique, ignoré
  ///   par le backend (non couvert par `DossierCreateSerializer`).
  /// - `for_self` (optionnel) : booléen — historique, ignoré par le backend.
  /// - `declarant` (optionnel) : informations déclarant (Map) — historique,
  ///   ignoré par le backend.
  /// - `numero_registre` / `annee_registre` / `date_naissance` (optionnels) :
  ///   transmis tels quels — le backend retrouve l'enregistrement
  ///   `RegistreCivil` correspondant et remplit lui-même `metadata`.
  /// - `is_for_third_party` / `third_party_relation` / `third_party_cni`
  ///   (optionnels) : transmis tels quels.
  ///
  /// Retourne l'identifiant du dossier créé.
  Future<String> submitCertificate(Map<String, dynamic> payload) async {
    final uiType = payload['type'] as String? ?? '';
    final backendType = kTypeUiToBackend[uiType] ?? uiType;

    final createPayload = <String, dynamic>{
      'type': backendType,
      'commune': payload['commune_id'],
      'notes': payload['notes'] ?? '',
    };
    if (payload['beneficiary'] != null) {
      createPayload['beneficiary'] = payload['beneficiary'];
    }
    if (payload.containsKey('for_self')) {
      createPayload['for_self'] = payload['for_self'];
    }
    if (payload['declarant'] != null) {
      createPayload['declarant'] = payload['declarant'];
    }
    for (final key in [
      'numero_registre',
      'annee_registre',
      'date_naissance',
      'is_for_third_party',
      'third_party_relation',
      'third_party_cni',
    ]) {
      if (payload.containsKey(key)) {
        createPayload[key] = payload[key];
      }
    }

    // 1) Création du dossier (statut "brouillon").
    final createRes = await client.post('/dossiers/', data: createPayload);
    if (createRes.statusCode != 200 && createRes.statusCode != 201) {
      throw ApiException(
        message: 'Erreur lors de la création du dossier',
        statusCode: createRes.statusCode,
      );
    }
    final createBody = createRes.data;
    final created =
        (createBody is Map<String, dynamic>) ? createBody['data'] : null;
    final dossierId =
        (created is Map<String, dynamic>) ? created['id'] as String? : null;
    if (dossierId == null) {
      throw const ApiException(
          message: 'Réponse invalide lors de la création du dossier');
    }

    // 2) Soumission du dossier (passage au statut "soumis").
    final submitRes = await client.post('/dossiers/$dossierId/submit/');
    if (submitRes.statusCode != 200) {
      throw ApiException(
        message: 'Erreur lors de la soumission du dossier',
        statusCode: submitRes.statusCode,
      );
    }

    return dossierId;
  }

  /// Téléverse une pièce jointe (ex : CNI recto/verso) liée à un dossier.
  ///
  /// Best-effort : en cas d'échec, l'erreur est journalisée mais
  /// PROPAGÉE (le provider décide s'il doit bloquer ou non), pour que
  /// l'utilisateur sache que sa pièce d'identité n'a pas été transmise.
  Future<void> uploadDocument({
    required String dossierId,
    required String filePath,
    String description = '',
  }) async {
    final fileName = filePath.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'dossier': dossierId,
      'description': description,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await client.post('/documents/', data: formData);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw ApiException(
        message: 'Échec de l\'envoi du document ($description)',
        statusCode: res.statusCode,
      );
    }
  }

  /// Télécharge le certificat PDF pour un dossier.
  /// Retourne le chemin local du fichier sauvegardé.
  Future<String> downloadCertificate(
    String dossierId, {
    void Function(int received, int total)? onProgress,
  }) async {
    if (kMockMode) {
      // Simulation en mode mock
      return MockService.downloadCertificate(dossierId);
    }
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/certificat_$dossierId.pdf';
    debugPrint('[DOWNLOAD] Téléchargement vers $savePath');
    await client.download(
      '/dossiers/$dossierId/download/',
      savePath,
      onReceiveProgress: onProgress,
    );
    return savePath;
  }
}
