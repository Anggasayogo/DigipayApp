import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/storage/session_storage.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String email,
    required String phoneNumber,
    required String fullName,
    required String password,
  });
  Future<bool> setupPin(String pin);
  Future<bool> verifyPin(String pin);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio = ApiClient.instance.dio;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data);
      if (user.token != null) {
        await SessionStorage.instance.saveToken(user.token!);
      }
      await SessionStorage.instance.saveUser(user.toJson());
      return user;
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getErrorMessage(e, fallbackMessage: 'Login gagal'));
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String phoneNumber,
    required String fullName,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'phone_number': phoneNumber,
          'full_name': fullName,
          'password': password,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data);
      if (user.token != null) {
        await SessionStorage.instance.saveToken(user.token!);
      }
      await SessionStorage.instance.saveUser(user.toJson());
      return user;
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getErrorMessage(e, fallbackMessage: 'Registrasi gagal'));
    }
  }

  @override
  Future<bool> setupPin(String pin) async {
    try {
      final response = await dio.post(
        ApiEndpoints.setupPin,
        data: {'pin': pin},
      );
      final success = response.data['success'] == true;
      if (success) {
        final user = SessionStorage.instance.getUser();
        if (user != null) {
          user['is_pin'] = true;
          await SessionStorage.instance.saveUser(user);
        }
      }
      return success;
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getErrorMessage(e, fallbackMessage: 'Setup PIN gagal'));
    }
  }

  @override
  Future<bool> verifyPin(String pin) async {
    try {
      final response = await dio.post(
        ApiEndpoints.verifyPin,
        data: {'pin': pin},
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getErrorMessage(e, fallbackMessage: 'PIN tidak valid'));
    }
  }
}
