import 'package:equatable/equatable.dart';
import '../../domain/entities/transfer_entity.dart';

enum TransferStatus { initial, loading, success, error }

class TransferState extends Equatable {
  final TransferStatus status;
  final TransferEntity? latestTransfer;
  final List<TransferEntity> history;
  final bool isHistoryLoading;
  final String? errorMessage;

  const TransferState({
    this.status = TransferStatus.initial,
    this.latestTransfer,
    this.history = const [],
    this.isHistoryLoading = false,
    this.errorMessage,
  });

  TransferState copyWith({
    TransferStatus? status,
    TransferEntity? latestTransfer,
    List<TransferEntity>? history,
    bool? isHistoryLoading,
    String? errorMessage,
  }) {
    return TransferState(
      status: status ?? this.status,
      latestTransfer: latestTransfer ?? this.latestTransfer,
      history: history ?? this.history,
      isHistoryLoading: isHistoryLoading ?? this.isHistoryLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        latestTransfer,
        history,
        isHistoryLoading,
        errorMessage,
      ];
}
