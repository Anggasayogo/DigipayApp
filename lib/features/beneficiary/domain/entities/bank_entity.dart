import 'package:equatable/equatable.dart';

class BankEntity extends Equatable {
  final String id;
  final String code;
  final String name;

  const BankEntity({
    required this.id,
    required this.code,
    required this.name,
  });

  @override
  List<Object?> get props => [id, code, name];
}
