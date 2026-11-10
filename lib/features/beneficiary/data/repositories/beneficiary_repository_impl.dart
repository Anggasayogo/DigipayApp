import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/bank_entity.dart';
import '../../domain/entities/beneficiary_entity.dart';
import '../../domain/repositories/beneficiary_repository.dart';
import '../datasources/beneficiary_remote_datasource.dart';

class BeneficiaryRepositoryImpl implements BeneficiaryRepository {
  final BeneficiaryRemoteDataSource remoteDataSource;

  BeneficiaryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BankEntity>> getBanks() async {
    return await remoteDataSource.getBanks();
  }

  @override
  Future<BeneficiaryEntity> checkAccount({
    required String bankId,
    required String accountNumber,
  }) async {
    return await remoteDataSource.checkAccount(bankId, accountNumber);
  }

  @override
  Future<BeneficiaryEntity> saveBeneficiary({
    required String bankId,
    required String accountNumber,
  }) async {
    final beneficiary = await remoteDataSource.saveBeneficiary(bankId, accountNumber);
    final favIds = getFavoriteIds();
    return beneficiary.copyWith(isFavorite: favIds.contains(beneficiary.id));
  }

  @override
  Future<List<BeneficiaryEntity>> getMyBeneficiaries() async {
    final list = await remoteDataSource.getMyBeneficiaries();
    final favIds = getFavoriteIds();
    return list.map((b) => b.copyWith(isFavorite: favIds.contains(b.id))).toList();
  }

  @override
  Future<void> toggleFavorite(String beneficiaryId) async {
    await SessionStorage.instance.toggleFavoriteBeneficiary(beneficiaryId);
  }

  @override
  List<String> getFavoriteIds() {
    return SessionStorage.instance.getFavoriteBeneficiaryIds();
  }
}
