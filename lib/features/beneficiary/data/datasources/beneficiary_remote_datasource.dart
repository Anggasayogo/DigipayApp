import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../models/bank_model.dart';
import '../models/beneficiary_model.dart';

abstract class BeneficiaryRemoteDataSource {
  Future<List<BankModel>> getBanks();
  Future<BeneficiaryModel> checkAccount(String bankId, String accountNumber);
  Future<BeneficiaryModel> saveBeneficiary(String bankId, String accountNumber);
  Future<List<BeneficiaryModel>> getMyBeneficiaries();
}

class BeneficiaryRemoteDataSourceImpl implements BeneficiaryRemoteDataSource {
  final Dio dio = ApiClient.instance.dio;

  @override
  Future<List<BankModel>> getBanks() async {
    try {
      final response = await dio.get(ApiEndpoints.banks);
      final list = response.data['data'] as List;
      return list.map((e) => BankModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getErrorMessage(e, fallbackMessage: 'Gagal memuat bank'));
    }
  }

  @override
  Future<BeneficiaryModel> checkAccount(String bankId, String accountNumber) async {
    try {
      final response = await dio.post(
        ApiEndpoints.checkAccount,
        data: {
          'bank_id': bankId,
          'account_number': accountNumber,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return BeneficiaryModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getErrorMessage(e, fallbackMessage: 'Rekening tidak ditemukan'));
    }
  }

  @override
  Future<BeneficiaryModel> saveBeneficiary(String bankId, String accountNumber) async {
    try {
      final response = await dio.post(
        ApiEndpoints.beneficiaries,
        data: {
          'bank_id': bankId,
          'account_number': accountNumber,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return BeneficiaryModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getErrorMessage(e, fallbackMessage: 'Gagal menyimpan rekening'));
    }
  }

  @override
  Future<List<BeneficiaryModel>> getMyBeneficiaries() async {
    try {
      final response = await dio.get(ApiEndpoints.beneficiaries);
      final list = response.data['data'] as List;
      return list.map((e) => BeneficiaryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getErrorMessage(e, fallbackMessage: 'Gagal memuat rekening tersimpan'));
    }
  }
}
