import '../../../core/network/dio_client.dart';
import '../../../core/errors/exceptions.dart';
import '../../auth/data/models/auth_response_model.dart';

class ProfileRemoteDatasource {
  final DioClient client;
  const ProfileRemoteDatasource({required this.client});

  Future<UserResponseModel> getProfile() async {
    final res = await client.get('/users/me/');
    if (res.statusCode == 200 && res.data != null) {
      final body = res.data;
      final inner = (body is Map<String, dynamic>) ? body['data'] : null;
      if (inner is Map<String, dynamic>) {
        return UserResponseModel.fromJson(inner);
      }
      if (body is Map<String, dynamic>) {
        return UserResponseModel.fromJson(body);
      }
    }
    throw const UnauthorizedException();
  }

  /// Met à jour les informations utilisateur via PATCH /api/users/{id}/
  /// (endpoint réel exposé par UserViewSet, champs autorisés :
  /// phone, first_name, last_name, commune — voir UserUpdateSerializer).
  Future<UserResponseModel> updateProfile(
      String userId, Map<String, dynamic> data) async {
    final res = await client.patch('/users/$userId/', data: data);
    final body = res.data;
    final inner = (body is Map<String, dynamic>) ? body['data'] : null;
    if (inner is Map<String, dynamic>) {
      return UserResponseModel.fromJson(inner);
    }
    if (body is Map<String, dynamic>) {
      return UserResponseModel.fromJson(body);
    }
    throw ApiException(
        message: 'Mise à jour échouée', statusCode: res.statusCode);
  }

  Future<void> changePin({
    required String oldPin,
    required String newPin,
  }) async {
    final res = await client.post('/auth/change-password/', data: {
      'old_password': oldPin,
      'new_password': newPin,
    });
    if (res.statusCode != 200) {
      throw ApiException(
          message: 'Changement de mot de passe échoué',
          statusCode: res.statusCode);
    }
  }
}
