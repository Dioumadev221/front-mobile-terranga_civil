import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../dossiers/data/remote_datasource.dart';

class NaissanceState {
  final bool isLoading;
  final String? error;
  final String? dossierId;

  const NaissanceState({
    this.isLoading = false,
    this.error,
    this.dossierId,
  });

  NaissanceState copyWith({
    bool? isLoading, String? error, String? dossierId, bool clearError = false,
  }) => NaissanceState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
        dossierId: dossierId ?? this.dossierId,
      );
}

class NaissanceNotifier extends StateNotifier<NaissanceState> {
  final DossiersRemoteDatasource _ds;
  NaissanceNotifier(this._ds) : super(const NaissanceState());

  /// Soumet une demande de certificat de naissance.
  ///
  /// [registre] et [anneeRegistre] sont vérifiés côté backend par rapport au
  /// Registre Civil (`RegistreCivil`) — c'est le serveur qui calcule et
  /// remplit `metadata` à partir de cet enregistrement (le client ne fournit
  /// jamais `metadata` directement).
  Future<String> submit({
    required String communeId,
    required String registre,
    required String anneeRegistre,
    required DateTime dateNaissance,
    bool forSelf = false,
    String? thirdPartyRelation,
    String? cniRectoPath,
    String? cniVersoPath,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final id = await _ds.submitCertificate({
        'type': 'naissance',
        'commune_id': communeId,
        'numero_registre': registre,
        'annee_registre': int.parse(anneeRegistre),
        'date_naissance': dateNaissance.toIso8601String().split('T').first,
        'is_for_third_party': !forSelf,
        if (!forSelf && thirdPartyRelation != null)
          'third_party_relation': thirdPartyRelation,
      });

      // Téléversement des pièces d'identité (CNI recto/verso) pour une
      // demande "pour une autre personne". Effectué après la création du
      // dossier car l'upload nécessite l'identifiant du dossier.
      String? uploadError;
      if (cniRectoPath != null) {
        try {
          await _ds.uploadDocument(
            dossierId: id,
            filePath: cniRectoPath,
            description: 'CNI recto',
          );
        } catch (_) {
          uploadError = 'L\'envoi de la CNI (recto) a échoué.';
        }
      }
      if (cniVersoPath != null) {
        try {
          await _ds.uploadDocument(
            dossierId: id,
            filePath: cniVersoPath,
            description: 'CNI verso',
          );
        } catch (_) {
          uploadError = (uploadError == null)
              ? 'L\'envoi de la CNI (verso) a échoué.'
              : 'L\'envoi de la CNI (recto et verso) a échoué.';
        }
      }

      state = state.copyWith(
        isLoading: false,
        dossierId: id,
        error: uploadError,
      );
      return id;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final naissanceProvider =
    StateNotifierProvider<NaissanceNotifier, NaissanceState>((ref) =>
        NaissanceNotifier(
            DossiersRemoteDatasource(client: ref.read(dioClientProvider))));
