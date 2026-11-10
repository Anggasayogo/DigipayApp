import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_entity.dart';

enum WalletStatus { initial, loading, loaded, error }

class WalletState extends Equatable {
  final WalletStatus status;
  final WalletEntity? wallet;
  final String? errorMessage;
  final bool isTopupSuccess;

  const WalletState({
    this.status = WalletStatus.initial,
    this.wallet,
    this.errorMessage,
    this.isTopupSuccess = false,
  });

  WalletState copyWith({
    WalletStatus? status,
    WalletEntity? wallet,
    String? errorMessage,
    bool? isTopupSuccess,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      errorMessage: errorMessage,
      isTopupSuccess: isTopupSuccess ?? this.isTopupSuccess,
    );
  }

  @override
  List<Object?> get props => [status, wallet, errorMessage, isTopupSuccess];
}
