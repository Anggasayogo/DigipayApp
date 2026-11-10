import '../entities/bank_entity.dart';
import '../entities/beneficiary_entity.dart';

abstract class BeneficiaryRepository {
  Future<List<BankEntity>> getBanks();
  Future<BeneficiaryEntity> checkAccount({
    required String bankId,
    required String accountNumber,
  });
  Future<BeneficiaryEntity> saveBeneficiary({
    required String bankId,
    required String accountNumber,
  });
  Future<List<BeneficiaryEntity>> getMyBeneficiaries();
  Future<void> toggleFavorite(String beneficiaryId);
  List<String> getFavoriteIds();
}
