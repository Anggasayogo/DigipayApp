import 'package:equatable/equatable.dart';

class TransferEntity extends Equatable {
  final String id;
  final String referenceNo;
  final String type;
  final String status; // PENDING, PROCESSING, SUCCESS, FAILED
  final num amount;
  final num fee;
  final num totalAmount;
  final String? failureReason;
  final String? description;
  final DateTime createdAt;
  final String recipientName;
  final String recipientBank;
  final String recipientAccount;

  const TransferEntity({
    required this.id,
    required this.referenceNo,
    required this.type,
    required this.status,
    required this.amount,
    required this.fee,
    required this.totalAmount,
    this.failureReason,
    this.description,
    required this.createdAt,
    required this.recipientName,
    required this.recipientBank,
    required this.recipientAccount,
  });

  bool get isSuccess => status == 'SUCCESS';
  bool get isProcessing => status == 'PROCESSING' || status == 'PENDING';
  bool get isFailed => status == 'FAILED';

  @override
  List<Object?> get props => [
        id,
        referenceNo,
        type,
        status,
        amount,
        fee,
        totalAmount,
        failureReason,
        description,
        createdAt,
        recipientName,
        recipientBank,
        recipientAccount,
      ];
}
