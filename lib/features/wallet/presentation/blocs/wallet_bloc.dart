import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(const WalletState()) {
    on<FetchBalanceEvent>(_onFetchBalance);
    on<TopupSubmittedEvent>(_onTopupSubmitted);
  }

  Future<void> _onFetchBalance(
    FetchBalanceEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (!event.isSilent) {
      emit(state.copyWith(status: WalletStatus.loading));
    }
    try {
      final wallet = await walletRepository.getBalance();
      emit(state.copyWith(
        status: WalletStatus.loaded,
        wallet: wallet,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onTopupSubmitted(
    TopupSubmittedEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.loading, isTopupSuccess: false));
    try {
      await walletRepository.topup(event.amount, description: event.description);
      final wallet = await walletRepository.getBalance();
      emit(state.copyWith(
        status: WalletStatus.loaded,
        wallet: wallet,
        isTopupSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
