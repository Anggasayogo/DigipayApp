import 'package:equatable/equatable.dart';

abstract class BeneficiaryEvent extends Equatable {
  const BeneficiaryEvent();
  @override
  List<Object?> get props => [];
}

class FetchBanksEvent extends BeneficiaryEvent {}

class FetchBeneficiariesEvent extends BeneficiaryEvent {}

class CheckAccountEvent extends BeneficiaryEvent {
  final String bankId;
  final String accountNumber;

  const CheckAccountEvent({required this.bankId, required this.accountNumber});

  @override
  List<Object?> get props => [bankId, accountNumber];
}

class SaveBeneficiaryEvent extends BeneficiaryEvent {
  final String bankId;
  final String accountNumber;

  const SaveBeneficiaryEvent({required this.bankId, required this.accountNumber});

  @override
  List<Object?> get props => [bankId, accountNumber];
}

class ToggleFavoriteBeneficiaryEvent extends BeneficiaryEvent {
  final String beneficiaryId;

  const ToggleFavoriteBeneficiaryEvent(this.beneficiaryId);

  @override
  List<Object?> get props => [beneficiaryId];
}

class ResetCheckAccountEvent extends BeneficiaryEvent {}
