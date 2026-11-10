import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digipay/core/theme/app_theme.dart';
import 'package:digipay/features/auth/domain/entities/user_entity.dart';
import 'package:digipay/features/auth/domain/repositories/auth_repository.dart';
import 'package:digipay/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:digipay/features/auth/presentation/pages/login_page.dart';
import 'package:digipay/features/auth/presentation/pages/setup_pin_page.dart';
import 'package:digipay/features/wallet/domain/entities/wallet_entity.dart';
import 'package:digipay/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:digipay/features/wallet/presentation/blocs/wallet_bloc.dart';
import 'package:digipay/features/wallet/presentation/pages/topup_page.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  Future<UserEntity> login(String email, String password) async {
    return const UserEntity(
      id: 'mock-1',
      email: 'angga.maulana@gmail.com',
      fullName: 'Angga Maulana',
      phoneNumber: '081111111111',
      isPin: true,
      token: 'jwt-token',
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<UserEntity> register({
    required String email,
    required String phoneNumber,
    required String fullName,
    required String password,
  }) async {
    return UserEntity(
      id: 'mock-2',
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      isPin: false,
    );
  }

  @override
  Future<bool> setupPin(String pin) async => true;

  @override
  Future<bool> verifyPin(String pin) async => pin == '123456';
}

class MockWalletRepository implements WalletRepository {
  @override
  Future<WalletEntity> getBalance() async {
    return const WalletEntity(
      currency: 'IDR',
      balance: 10000000,
      availableBalance: 10000000,
      amountOnHold: 0,
    );
  }

  @override
  Future<void> topup(int amount, {String? description}) async {}
}

void main() {
  testWidgets('QA-UI-01: LoginPage renders correctly with red branding and inputs', (tester) async {
    final authRepo = MockAuthRepository();
    final authBloc = AuthBloc(authRepository: authRepo);

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: BlocProvider.value(
          value: authBloc,
          child: const LoginPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Brand title & header
    expect(find.text('DigiPay'), findsOneWidget);
    expect(find.text('Masuk ke Akun Anda'), findsOneWidget);
    expect(find.text('Masuk Sekarang'), findsOneWidget);
    expect(find.text('Daftar Sekarang'), findsOneWidget);
    expect(find.textContaining('angga.maulana@gmail.com'), findsOneWidget);
  });

  testWidgets('QA-UI-02: SetupPinPage keypad displays 1-9, 0 and backspace', (tester) async {
    final authRepo = MockAuthRepository();
    final authBloc = AuthBloc(authRepository: authRepo);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: BlocProvider.value(
          value: authBloc,
          child: const SetupPinPage(),
        ),
      ),
    );

    expect(find.text('Buat PIN Keamanan'), findsOneWidget);
    expect(find.text('Buat 6 Digit PIN'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
  });

  testWidgets('QA-UI-03: TopupPage renders quick nominal chips and input', (tester) async {
    final walletRepo = MockWalletRepository();
    final walletBloc = WalletBloc(walletRepository: walletRepo);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: BlocProvider.value(
          value: walletBloc,
          child: const TopupPage(),
        ),
      ),
    );

    expect(find.text('Isi Saldo (Top Up)'), findsOneWidget);
    expect(find.text('Pilih Nominal Top Up'), findsOneWidget);
    expect(find.text('Rp 50.000'), findsOneWidget);
    expect(find.text('Rp 100.000'), findsOneWidget);
    expect(find.text('Isi Saldo Sekarang'), findsOneWidget);
  });
}
