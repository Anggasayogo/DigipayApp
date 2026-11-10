import '../../domain/entities/transfer_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_remote_datasource.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferRemoteDataSource remoteDataSource;

  TransferRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TransferEntity> createTransfer({
    required String beneficiaryId,
    required int amount,
    required String pin,
    String? description,
    required String idempotencyKey,
  }) async {
    return await remoteDataSource.createTransfer(
      beneficiaryId: beneficiaryId,
      amount: amount,
      pin: pin,
      description: description,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<List<TransferEntity>> getTransfers({String? status, int page = 1, int limit = 20}) async {
    return await remoteDataSource.getTransfers(status: status, page: page, limit: limit);
  }

  @override
  Future<TransferEntity> getTransferById(String id) async {
    return await remoteDataSource.getTransferById(id);
  }
}
