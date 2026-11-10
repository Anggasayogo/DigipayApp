import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WalletEntity> getBalance() async {
    return await remoteDataSource.getBalance();
  }

  @override
  Future<void> topup(int amount, {String? description}) async {
    return await remoteDataSource.topup(amount, description: description);
  }
}
