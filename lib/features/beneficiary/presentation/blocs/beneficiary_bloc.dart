import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/beneficiary_repository.dart';
import 'beneficiary_event.dart';
import 'beneficiary_state.dart';

class BeneficiaryBloc extends Bloc<BeneficiaryEvent, BeneficiaryState> {
  final BeneficiaryRepository beneficiaryRepository;

  BeneficiaryBloc({required this.beneficiaryRepository}) : super(const BeneficiaryState()) {
    on<FetchBanksEvent>(_onFetchBanks);
    on<FetchBeneficiariesEvent>(_onFetchBeneficiaries);
    on<CheckAccountEvent>(_onCheckAccount);
    on<SaveBeneficiaryEvent>(_onSaveBeneficiary);
    on<ToggleFavoriteBeneficiaryEvent>(_onToggleFavorite);
    on<ResetCheckAccountEvent>((event, emit) => emit(state.copyWith(clearChecked: true)));
  }

  Future<void> _onFetchBanks(
    FetchBanksEvent event,
    Emitter<BeneficiaryState> emit,
  ) async {
    try {
      final banks = await beneficiaryRepository.getBanks();
      emit(state.copyWith(banks: banks));
    } catch (e) {
      // Keep existing banks if any
    }
  }

  Future<void> _onFetchBeneficiaries(
    FetchBeneficiariesEvent event,
    Emitter<BeneficiaryState> emit,
  ) async {
    emit(state.copyWith(status: BeneficiaryStatus.loading));
    try {
      final beneficiaries = await beneficiaryRepository.getMyBeneficiaries();
      emit(state.copyWith(
        status: BeneficiaryStatus.loaded,
        beneficiaries: beneficiaries,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BeneficiaryStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onCheckAccount(
    CheckAccountEvent event,
    Emitter<BeneficiaryState> emit,
  ) async {
    emit(state.copyWith(isChecking: true, errorMessage: null, clearChecked: true));
    try {
      final checked = await beneficiaryRepository.checkAccount(
        bankId: event.bankId,
        accountNumber: event.accountNumber,
      );
      emit(state.copyWith(
        isChecking: false,
        checkedAccount: checked,
      ));
    } catch (e) {
      emit(state.copyWith(
        isChecking: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSaveBeneficiary(
    SaveBeneficiaryEvent event,
    Emitter<BeneficiaryState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, errorMessage: null, successMessage: null));
    try {
      final saved = await beneficiaryRepository.saveBeneficiary(
        bankId: event.bankId,
        accountNumber: event.accountNumber,
      );
      final updatedList = [saved, ...state.beneficiaries.where((b) => b.id != saved.id)];
      emit(state.copyWith(
        isSaving: false,
        beneficiaries: updatedList,
        checkedAccount: saved,
        successMessage: 'Rekening penerima berhasil disimpan!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteBeneficiaryEvent event,
    Emitter<BeneficiaryState> emit,
  ) async {
    await beneficiaryRepository.toggleFavorite(event.beneficiaryId);
    final favIds = beneficiaryRepository.getFavoriteIds();
    final updated = state.beneficiaries.map((b) {
      return b.copyWith(isFavorite: favIds.contains(b.id));
    }).toList();
    emit(state.copyWith(beneficiaries: updated));
  }
}
