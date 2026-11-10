import '../entities/transfer_entity.dart';

abstract class TransferRepository {
  Future<TransferEntity> createTransfer({
    required String beneficiaryId,
    required int amount,
    required String pin,
    String? description,
    required String idempotencyKey,
  });

  Future<List<TransferEntity>> getTransfers({String? status, int page = 1, int limit = 20});
  Future<TransferEntity> getTransferById(String id);
}
