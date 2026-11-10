import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class FetchBalanceEvent extends WalletEvent {
  final bool isSilent;
  const FetchBalanceEvent({this.isSilent = false});

  @override
  List<Object?> get props => [isSilent];
}

class TopupSubmittedEvent extends WalletEvent {
  final int amount;
  final String? description;

  const TopupSubmittedEvent({required this.amount, this.description});

  @override
  List<Object?> get props => [amount, description];
}
