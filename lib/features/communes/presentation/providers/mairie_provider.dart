import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/mairie_datasource.dart';

/// Position par défaut (Dakar Plateau) si la géolocalisation est refusée /
/// indisponible — la mairie la plus proche reste affichée pour la démo.
const _defaultLat = 14.6928;
const _defaultLng = -17.4467;

final mairieDsProvider = Provider<MairieRemoteDatasource>(
    (ref) => MairieRemoteDatasource(client: ref.read(dioClientProvider)));

/// Récupère la position de l'appareil (avec repli Dakar) puis la liste des
/// mairies proches triées par distance.
final mairiesProchesProvider =
    FutureProvider.autoDispose<List<MairieModel>>((ref) async {
  double lat = _defaultLat, lng = _defaultLng;
  try {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (enabled) {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 8),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      }
    }
  } catch (_) {
    // Repli silencieux sur la position par défaut.
  }
  return ref.read(mairieDsProvider).mairiesProches(lat, lng);
});
