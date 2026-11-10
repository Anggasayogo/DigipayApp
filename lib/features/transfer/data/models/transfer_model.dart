import '../../domain/entities/transfer_entity.dart';

class TransferModel extends TransferEntity {
  const TransferModel({
    required super.id,
    required super.referenceNo,
    required super.type,
    required super.status,
    required super.amount,
    required super.fee,
    required super.totalAmount,
    super.failureReason,
    super.description,
    required super.createdAt,
    required super.recipientName,
    required super.recipientBank,
    required super.recipientAccount,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    final ben = json['beneficiary'] as Map<String, dynamic>?;
    final metadata = json['metadata'] as Map<String, dynamic>?;

    String rName = ben?['account_holder_name'] ?? metadata?['beneficiary_name'] ?? 'Penerima Transfer';
    String rBank = ben?['bank_name'] ?? ben?['bank_code'] ?? metadata?['bank_name'] ?? 'Bank Domestik';
    String rAcc = ben?['account_number'] ?? ben?['masked_account_number'] ?? metadata?['account_number'] ?? '-';

    return TransferModel(
      id: json['id']?.toString() ?? '',
      referenceNo: json['reference_no']?.toString() ?? json['referenceNo']?.toString() ?? '-',
      type: json['type']?.toString() ?? 'TRANSFER',
      status: json['status']?.toString().toUpperCase() ?? 'PROCESSING',
      amount: num.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      fee: num.tryParse(json['fee']?.toString() ?? '6500') ?? 6500,
      totalAmount: num.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      failureReason: json['failure_reason']?.toString(),
      description: json['description']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      recipientName: rName,
      recipientBank: rBank,
      recipientAccount: rAcc,
    );
  }
}
