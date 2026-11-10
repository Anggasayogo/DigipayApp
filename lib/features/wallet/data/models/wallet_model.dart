import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.currency,
    required super.balance,
    required super.availableBalance,
    required super.amountOnHold,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      currency: json['currency']?.toString() ?? 'IDR',
      balance: num.tryParse(json['balance']?.toString() ?? '0') ?? 0,
      availableBalance: num.tryParse(json['available_balance']?.toString() ?? json['balance']?.toString() ?? '0') ?? 0,
      amountOnHold: num.tryParse(json['amount_on_hold']?.toString() ?? json['reserved_balance']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'balance': balance,
      'available_balance': availableBalance,
      'amount_on_hold': amountOnHold,
    };
  }
}
