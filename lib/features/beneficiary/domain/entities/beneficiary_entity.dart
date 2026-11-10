import 'package:equatable/equatable.dart';

class BeneficiaryEntity extends Equatable {
  final String id;
  final String bankId;
  final String bankCode;
  final String bankName;
  final String accountNumber;
  final String? maskedAccountNumber;
  final String accountHolderName;
  final bool isFavorite;

  const BeneficiaryEntity({
    required this.id,
    required this.bankId,
    required this.bankCode,
    required this.bankName,
    required this.accountNumber,
    this.maskedAccountNumber,
    required this.accountHolderName,
    this.isFavorite = false,
  });

  BeneficiaryEntity copyWith({
    String? id,
    String? bankId,
    String? bankCode,
    String? bankName,
    String? accountNumber,
    String? maskedAccountNumber,
    String? accountHolderName,
    bool? isFavorite,
  }) {
    return BeneficiaryEntity(
      id: id ?? this.id,
      bankId: bankId ?? this.bankId,
      bankCode: bankCode ?? this.bankCode,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      maskedAccountNumber: maskedAccountNumber ?? this.maskedAccountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bankId,
        bankCode,
        bankName,
        accountNumber,
        maskedAccountNumber,
        accountHolderName,
        isFavorite,
      ];
}
