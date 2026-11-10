import '../../domain/entities/beneficiary_entity.dart';

class BeneficiaryModel extends BeneficiaryEntity {
  const BeneficiaryModel({
    required super.id,
    required super.bankId,
    required super.bankCode,
    required super.bankName,
    required super.accountNumber,
    super.maskedAccountNumber,
    required super.accountHolderName,
    super.isFavorite,
  });

  factory BeneficiaryModel.fromJson(Map<String, dynamic> json, {bool isFavorite = false}) {
    return BeneficiaryModel(
      id: json['id']?.toString() ?? '',
      bankId: json['bank_id']?.toString() ?? json['bankId']?.toString() ?? '',
      bankCode: json['bank_code']?.toString() ?? json['bankCode']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? json['bankName']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? json['accountNumber']?.toString() ?? '',
      maskedAccountNumber: json['masked_account_number']?.toString(),
      accountHolderName: json['account_holder_name']?.toString() ?? json['accountHolderName']?.toString() ?? '',
      isFavorite: isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_id': bankId,
      'bank_code': bankCode,
      'bank_name': bankName,
      'account_number': accountNumber,
      'masked_account_number': maskedAccountNumber,
      'account_holder_name': accountHolderName,
    };
  }
}
