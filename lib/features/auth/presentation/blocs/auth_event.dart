import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterSubmitted extends AuthEvent {
  final String email;
  final String phoneNumber;
  final String fullName;
  final String password;

  const AuthRegisterSubmitted({
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    required this.password,
  });

  @override
  List<Object?> get props => [email, phoneNumber, fullName, password];
}

class AuthSetupPinSubmitted extends AuthEvent {
  final String pin;

  const AuthSetupPinSubmitted(this.pin);

  @override
  List<Object?> get props => [pin];
}

class AuthLogoutRequested extends AuthEvent {}
