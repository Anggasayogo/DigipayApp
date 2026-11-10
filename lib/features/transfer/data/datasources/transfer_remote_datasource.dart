import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../models/transfer_model.dart';

abstract class TransferRemoteDataSource {
  Future<TransferModel> createTransfer({
    required String beneficiaryId,
    required int amount,
    required String pin,
    String? description,
    required String idempotencyKey,
  });

  Future<List<TransferModel>> getTransfers({String? status, int page = 1, int limit = 20});
  Future<TransferModel> getTransferById(String id);
}

class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  final Dio dio = ApiClient.instance.dio;

  @override
  Future<TransferModel> createTransfer({
    required String beneficiaryId,
    required int amount,
    required String pin,
    String? description,
    required String idempotencyKey,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.transfers,
        data: {
          'beneficiary_id': beneficiaryId,
          'amount': amount,
          'pin': pin,
          if (description != null) 'description': description,
        },
        options: Options(
          headers: {
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );

      final data = response.data['data']['transaction'] as Map<String, dynamic>;
      return TransferModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getErrorMessage(e, fallbackMessage: 'Gagal memproses transfer'));
    }
  }

  @override
  Future<List<TransferModel>> getTransfers({String? status, int page = 1, int limit = 20}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.transfers,
        queryParameters: {
          if (status != null && status != 'ALL') 'status': status,
          'page': page,
          'limit': limit,
        },
      );
      final list = response.data['data'] as List;
      return list.map((e) => TransferModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getErrorMessage(e, fallbackMessage: 'Gagal memuat riwayat transaksi'));
    }
  }

  @override
  Future<TransferModel> getTransferById(String id) async {
    try {
      final response = await dio.get('${ApiEndpoints.transfers}/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return TransferModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getErrorMessage(e, fallbackMessage: 'Detail transaksi tidak ditemukan'));
    }
  }
}
