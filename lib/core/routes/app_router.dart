import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../features/auth/presentation/blocs/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/setup_pin_page.dart';
import '../../features/beneficiary/domain/entities/beneficiary_entity.dart';
import '../../features/beneficiary/presentation/pages/check_account_page.dart';
import '../../features/beneficiary/presentation/pages/saved_beneficiaries_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/main_navigation/pages/main_nav_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/transfer/domain/entities/transfer_entity.dart';
import '../../features/transfer/presentation/pages/transfer_input_page.dart';
import '../../features/transfer/presentation/pages/transfer_result_page.dart';
import '../../features/wallet/presentation/pages/topup_page.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: ChuckerFlutter.navigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (state.matchedLocation == '/') {
        if (isAuthenticated) {
          if (authState.user?.isPin == false) {
            return '/setup-pin';
          }
          return '/home';
        }
        return '/login';
      }

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        if (authState.user?.isPin == false) {
          return '/setup-pin';
        }
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/setup-pin',
        builder: (context, state) => const SetupPinPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavPage(),
      ),
      GoRoute(
        path: '/transfer-input',
        builder: (context, state) {
          final beneficiary = state.extra as BeneficiaryEntity?;
          return TransferInputPage(initialBeneficiary: beneficiary);
        },
      ),
      GoRoute(
        path: '/transfer-result',
        builder: (context, state) {
          final transfer = state.extra as TransferEntity;
          return TransferResultPage(transfer: transfer);
        },
      ),
      GoRoute(
        path: '/check-account',
        builder: (context, state) => const CheckAccountPage(),
      ),
      GoRoute(
        path: '/saved-beneficiaries',
        builder: (context, state) => const SavedBeneficiariesPage(),
      ),
      GoRoute(
        path: '/topup',
        builder: (context, state) => const TopupPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
