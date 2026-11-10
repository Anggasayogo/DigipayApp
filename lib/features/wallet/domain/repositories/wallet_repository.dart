import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<WalletEntity> getBalance();
  Future<void> topup(int amount, {String? description});
}
