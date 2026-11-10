import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/network/signature_helper.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getBalance();
  Future<void> topup(int amount, {String? description});
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final Dio dio = ApiClient.instance.dio;

  @override
  Future<WalletModel> getBalance() async {
    try {
      final response = await dio.get(ApiEndpoints.balance);
      final data = response.data['data'] as Map<String, dynamic>;
      return WalletModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getErrorMessage(e, fallbackMessage: 'Gagal memuat saldo'));
    }
  }

  @override
  Future<void> topup(int amount, {String? description}) async {
    try {
      final body = {
        'amount': amount,
        if (description != null) 'description': description,
      };

      final headers = SignatureHelper.generateTransactionHeaders(
        method: 'POST',
        path: ApiEndpoints.topup,
        body: body,
      );

      await dio.post(
        ApiEndpoints.topup,
        data: body,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getErrorMessage(e, fallbackMessage: 'Topup gagal'));
    }
  }
}
