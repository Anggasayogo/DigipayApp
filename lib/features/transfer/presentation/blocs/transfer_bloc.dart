import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/transfer_repository.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransferRepository transferRepository;
  final _uuid = const Uuid();

  TransferBloc({required this.transferRepository}) : super(const TransferState()) {
    on<CreateTransferEvent>(_onCreateTransfer);
    on<FetchTransferHistoryEvent>(_onFetchHistory);
    on<FetchTransferDetailEvent>(_onFetchDetail);
  }

  Future<void> _onCreateTransfer(
    CreateTransferEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(state.copyWith(status: TransferStatus.loading, errorMessage: null));
    try {
      final idempotencyKey = _uuid.v4();
      final transfer = await transferRepository.createTransfer(
        beneficiaryId: event.beneficiaryId,
        amount: event.amount,
        pin: event.pin,
        description: event.description,
        idempotencyKey: idempotencyKey,
      );

      final updatedHistory = [transfer, ...state.history];
      emit(state.copyWith(
        status: TransferStatus.success,
        latestTransfer: transfer,
        history: updatedHistory,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransferStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onFetchHistory(
    FetchTransferHistoryEvent event,
    Emitter<TransferState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(state.copyWith(isHistoryLoading: true));
    }
    try {
      final history = await transferRepository.getTransfers(status: event.status);
      emit(state.copyWith(
        history: history,
        isHistoryLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isHistoryLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onFetchDetail(
    FetchTransferDetailEvent event,
    Emitter<TransferState> emit,
  ) async {
    try {
      final detail = await transferRepository.getTransferById(event.id);
      final updatedHistory = state.history.map((t) => t.id == detail.id ? detail : t).toList();
      emit(state.copyWith(latestTransfer: detail, history: updatedHistory));
    } catch (_) {}
  }
}
