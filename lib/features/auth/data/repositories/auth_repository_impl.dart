import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String phoneNumber,
    required String fullName,
    required String password,
  }) async {
    return await remoteDataSource.register(
      email: email,
      phoneNumber: phoneNumber,
      fullName: fullName,
      password: password,
    );
  }

  @override
  Future<bool> setupPin(String pin) async {
    return await remoteDataSource.setupPin(pin);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    return await remoteDataSource.verifyPin(pin);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await SessionStorage.instance.getToken();
    final userData = SessionStorage.instance.getUser();

    if (token != null && userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await SessionStorage.instance.clearSession();
  }
}
