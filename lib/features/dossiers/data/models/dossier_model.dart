/// Mapping des statuts backend (Django, anglais) vers les codes utilisés
/// par l'UI Flutter (français) — voir [StatusBadge], [DossierProgressStepper]
/// et [AppFormatters.statusLabel].
const Map<String, String> kStatusBackendToUi = {
  'draft': 'en_cours',
  'submitted': 'soumis',
  'in_review': 'en_verification',
  'generated': 'valide',
  'validated': 'valide',
  'approved': 'valide',
  'delivered': 'pret',
  'completed': 'pret',
  'rejected': 'rejete',
};

/// Mapping inverse, utile si l'UI doit renvoyer un statut au backend.
const Map<String, String> kStatusUiToBackend = {
  'en_cours': 'draft',
  'soumis': 'submitted',
  'en_verification': 'in_review',
  'pret': 'approved',
  'rejete': 'rejected',
};

/// Mapping des types de dossier backend (Django) vers les codes UI Flutter.
const Map<String, String> kTypeBackendToUi = {
  'birth_certificate': 'naissance',
  'marriage_certificate': 'mariage',
  'death_certificate': 'deces',
  'residence_certificate': 'residence',
  'other': 'other',
};

/// Mapping inverse, utilisé lors de la soumission d'une nouvelle demande.
const Map<String, String> kTypeUiToBackend = {
  'naissance': 'birth_certificate',
  'mariage': 'marriage_certificate',
  'deces': 'death_certificate',
  'residence': 'residence_certificate',
  'other': 'other',
};

class DossierModel {
  final String id;
  final String type;
  final String status;
  final DateTime createdAt;
  final String? communeNom;
  final String? beneficiaryNom;
  final int? fraisFCFA;
  final String? agentNom;
  final String? agentPhone;

  const DossierModel({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
    this.communeNom,
    this.beneficiaryNom,
    this.fraisFCFA,
    this.agentNom,
    this.agentPhone,
  });

  /// Progression calculée depuis le statut UI (affichage uniquement)
  double get progress {
    switch (status) {
      case 'soumis':    return 0.25;
      case 'en_verification': return 0.5;
      case 'valide':    return 0.75;
      case 'pret':      return 1.0;
      case 'rejete':    return 0.3;
      default:          return 0.1; // en_cours / draft
    }
  }

  factory DossierModel.fromJson(Map<String, dynamic> json) {
    final backendType = json['type'] as String? ?? '';
    final backendStatus = json['status'] as String? ?? 'draft';
    return DossierModel(
      id: json['id'] as String? ?? '',
      // Codes backend (Django, anglais) traduits vers les codes UI
      // (français) attendus par StatusBadge / DossierProgressStepper /
      // AppFormatters et les écrans de dossiers.
      type: kTypeBackendToUi[backendType] ?? backendType,
      status: kStatusBackendToUi[backendStatus] ?? 'en_cours',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      // 'commune_name' = champ réel renvoyé par DossierListSerializer /
      // DossierDetailSerializer côté backend.
      communeNom: json['commune_name'] as String?,
      // Exposés par DossierListSerializer / DossierDetailSerializer
      // (beneficiary_nom, frais — voir apps/dossiers/serializers.py).
      beneficiaryNom: json['beneficiary_nom'] as String?,
      fraisFCFA: json['frais'] as int?,
      // 'agent_name' = champ déjà exposé par DossierListSerializer /
      // DossierDetailSerializer (assigned_agent.full_name).
      agentNom: json['agent_name'] as String?,
      agentPhone: (json['assigned_agent'] as Map<String, dynamic>?)?['phone']
          as String?,
    );
  }
}
