import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String currency;
  final num balance;
  final num availableBalance;
  final num amountOnHold;

  const WalletEntity({
    required this.currency,
    required this.balance,
    required this.availableBalance,
    required this.amountOnHold,
  });

  @override
  List<Object?> get props => [currency, balance, availableBalance, amountOnHold];
}
