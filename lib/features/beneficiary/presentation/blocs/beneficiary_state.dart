import 'package:equatable/equatable.dart';
import '../../domain/entities/bank_entity.dart';
import '../../domain/entities/beneficiary_entity.dart';

enum BeneficiaryStatus { initial, loading, loaded, error }

class BeneficiaryState extends Equatable {
  final BeneficiaryStatus status;
  final List<BankEntity> banks;
  final List<BeneficiaryEntity> beneficiaries;
  final BeneficiaryEntity? checkedAccount;
  final bool isChecking;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const BeneficiaryState({
    this.status = BeneficiaryStatus.initial,
    this.banks = const [],
    this.beneficiaries = const [],
    this.checkedAccount,
    this.isChecking = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  List<BeneficiaryEntity> get favoriteBeneficiaries =>
      beneficiaries.where((b) => b.isFavorite).toList();

  BeneficiaryState copyWith({
    BeneficiaryStatus? status,
    List<BankEntity>? banks,
    List<BeneficiaryEntity>? beneficiaries,
    BeneficiaryEntity? checkedAccount,
    bool? isChecking,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearChecked = false,
  }) {
    return BeneficiaryState(
      status: status ?? this.status,
      banks: banks ?? this.banks,
      beneficiaries: beneficiaries ?? this.beneficiaries,
      checkedAccount: clearChecked ? null : (checkedAccount ?? this.checkedAccount),
      isChecking: isChecking ?? this.isChecking,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        banks,
        beneficiaries,
        checkedAccount,
        isChecking,
        isSaving,
        errorMessage,
        successMessage,
      ];
}
