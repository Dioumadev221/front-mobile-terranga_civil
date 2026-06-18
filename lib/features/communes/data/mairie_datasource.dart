import '../../../core/network/dio_client.dart';
import '../../../core/errors/exceptions.dart';

/// Une mairie renvoyée par `/api/communes/mairies/proches/`.
class MairieModel {
  final int id;
  final String nom;
  final String communeNom;
  final String adresse;
  final double latitude;
  final double longitude;
  final String telephone;
  final String horaires;
  final double? distanceKm;

  const MairieModel({
    required this.id,
    required this.nom,
    required this.communeNom,
    required this.adresse,
    required this.latitude,
    required this.longitude,
    this.telephone = '',
    this.horaires = '',
    this.distanceKm,
  });

  factory MairieModel.fromJson(Map<String, dynamic> j) => MairieModel(
        id: (j['id'] as num?)?.toInt() ?? 0,
        nom: j['nom'] as String? ?? 'Mairie',
        communeNom: j['commune_nom'] as String? ?? '',
        adresse: j['adresse'] as String? ?? '',
        latitude: double.tryParse('${j['latitude']}') ?? 0,
        longitude: double.tryParse('${j['longitude']}') ?? 0,
        telephone: j['telephone'] as String? ?? '',
        horaires: j['horaires'] as String? ?? '',
        distanceKm: (j['distance_km'] is num)
            ? (j['distance_km'] as num).toDouble()
            : double.tryParse('${j['distance_km']}'),
      );
}

class MairieRemoteDatasource {
  final DioClient client;
  const MairieRemoteDatasource({required this.client});

  /// Mairies les plus proches d'un point. Backend :
  /// GET /api/communes/mairies/proches/?lat=&lng=
  ///  -> { data: { commune, count, mairies: [ {…, distance_km} ] } }
  Future<List<MairieModel>> mairiesProches(double lat, double lng) async {
    final res = await client.get(
      '/communes/mairies/proches/',
      queryParameters: {'lat': lat, 'lng': lng},
    );
    if (res.statusCode == 200 && res.data is Map) {
      final body = res.data as Map<String, dynamic>;
      final data = body['data'];
      final list = (data is Map<String, dynamic>) ? data['mairies'] : null;
      if (list is List) {
        return list
            .map((e) => MairieModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    throw const ApiException(message: 'Impossible de charger les mairies');
  }
}
