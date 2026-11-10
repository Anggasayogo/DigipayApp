import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/routes/app_router.dart';
import 'core/storage/session_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/auth/presentation/blocs/auth_event.dart';
import 'features/beneficiary/data/datasources/beneficiary_remote_datasource.dart';
import 'features/beneficiary/data/repositories/beneficiary_repository_impl.dart';
import 'features/beneficiary/presentation/blocs/beneficiary_bloc.dart';
import 'features/transfer/data/datasources/transfer_remote_datasource.dart';
import 'features/transfer/data/repositories/transfer_repository_impl.dart';
import 'features/transfer/presentation/blocs/transfer_bloc.dart';
import 'features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'features/wallet/data/repositories/wallet_repository_impl.dart';
import 'features/wallet/presentation/blocs/wallet_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Chucker: record network calls without invasive overlay toasts that cause ANR
  ChuckerFlutter.showNotification = false;

  // Initialize Indonesian locale data for date formatting
  await initializeDateFormatting('id_ID', null);

  // Initialize Local Session Storage
  await SessionStorage.instance.init();

  // Repositories initialization
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(),
  );

  final walletRepository = WalletRepositoryImpl(
    remoteDataSource: WalletRemoteDataSourceImpl(),
  );

  final beneficiaryRepository = BeneficiaryRepositoryImpl(
    remoteDataSource: BeneficiaryRemoteDataSourceImpl(),
  );

  final transferRepository = TransferRepositoryImpl(
    remoteDataSource: TransferRemoteDataSourceImpl(),
  );

  // Blocs initialization
  final authBloc = AuthBloc(authRepository: authRepository)..add(AuthCheckRequested());
  final walletBloc = WalletBloc(walletRepository: walletRepository);
  final beneficiaryBloc = BeneficiaryBloc(beneficiaryRepository: beneficiaryRepository);
  final transferBloc = TransferBloc(transferRepository: transferRepository);

  final router = createRouter(authBloc);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: walletRepository),
        RepositoryProvider.value(value: beneficiaryRepository),
        RepositoryProvider.value(value: transferRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: walletBloc),
          BlocProvider.value(value: beneficiaryBloc),
          BlocProvider.value(value: transferBloc),
        ],
        child: DigiPayApp(router: router),
      ),
    ),
  );
}

class DigiPayApp extends StatelessWidget {
  final dynamic router;

  const DigiPayApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DigiPay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
