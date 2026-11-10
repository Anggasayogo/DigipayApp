import 'package:equatable/equatable.dart';

abstract class TransferEvent extends Equatable {
  const TransferEvent();
  @override
  List<Object?> get props => [];
}

class CreateTransferEvent extends TransferEvent {
  final String beneficiaryId;
  final int amount;
  final String pin;
  final String? description;

  const CreateTransferEvent({
    required this.beneficiaryId,
    required this.amount,
    required this.pin,
    this.description,
  });

  @override
  List<Object?> get props => [beneficiaryId, amount, pin, description];
}

class FetchTransferHistoryEvent extends TransferEvent {
  final String? status;
  final bool isRefresh;

  const FetchTransferHistoryEvent({this.status, this.isRefresh = false});

  @override
  List<Object?> get props => [status, isRefresh];
}

class FetchTransferDetailEvent extends TransferEvent {
  final String id;

  const FetchTransferDetailEvent(this.id);

  @override
  List<Object?> get props => [id];
}
