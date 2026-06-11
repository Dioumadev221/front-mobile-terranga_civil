import '../repository.dart';

class RegisterUsecase {
  final AuthRepository repository;
  const RegisterUsecase(this.repository);

  /// Retourne l'identifiant à utiliser pour l'écran de vérification OTP,
  /// ainsi que le code OTP de debug (mode DEBUG uniquement, sinon `null`).
  Future<({String identifier, String? otpDebug})> call({
    required String prenom,
    required String nom,
    required String password,
    String? phone,
    String? email,
  }) =>
      repository.register(
        prenom: prenom,
        nom: nom,
        password: password,
        phone: phone,
        email: email,
      );
}
