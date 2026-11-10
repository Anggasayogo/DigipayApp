import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register({
    required String email,
    required String phoneNumber,
    required String fullName,
    required String password,
  });
  Future<bool> setupPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
}
