import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/pin_keypad.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';

class SetupPinPage extends StatefulWidget {
  const SetupPinPage({super.key});

  @override
  State<SetupPinPage> createState() => _SetupPinPageState();
}

class _SetupPinPageState extends State<SetupPinPage> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _errorMessage;

  void _onDigitPressed(String digit) {
    setState(() {
      _errorMessage = null;
      if (!_isConfirming) {
        if (_firstPin.length < 6) {
          _firstPin += digit;
          if (_firstPin.length == 6) {
            // Move to confirmation step after slight delay
            Future.delayed(const Duration(milliseconds: 250), () {
              if (mounted) {
                setState(() {
                  _isConfirming = true;
                });
              }
            });
          }
        }
      } else {
        if (_confirmPin.length < 6) {
          _confirmPin += digit;
          if (_confirmPin.length == 6) {
            _validateAndSubmit();
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      _errorMessage = null;
      if (!_isConfirming) {
        if (_firstPin.isNotEmpty) {
          _firstPin = _firstPin.substring(0, _firstPin.length - 1);
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          // Go back to first PIN entry
          _isConfirming = false;
          _firstPin = '';
        }
      }
    });
  }

  void _validateAndSubmit() {
    if (_firstPin == _confirmPin) {
      context.read<AuthBloc>().add(AuthSetupPinSubmitted(_firstPin));
    } else {
      setState(() {
        _errorMessage = 'PIN tidak cocok. Silakan ulangi pembuatan PIN.';
        _confirmPin = '';
        _firstPin = '';
        _isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.pinSetupSuccess || (state.status == AuthStatus.authenticated && state.user?.isPin == true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN transaksi berhasil dibuat!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/home');
        } else if (state.status == AuthStatus.error && state.errorMessage != null) {
          setState(() {
            _errorMessage = state.errorMessage;
            _confirmPin = '';
            _firstPin = '';
            _isConfirming = false;
          });
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: _isConfirming
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () {
                      setState(() {
                        _isConfirming = false;
                        _confirmPin = '';
                        _firstPin = '';
                        _errorMessage = null;
                      });
                    },
                  )
                : null,
            title: const Text('Buat PIN Keamanan'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.shield_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isConfirming ? 'Konfirmasi PIN Anda' : 'Buat 6 Digit PIN',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _isConfirming
                          ? 'Masukkan kembali 6 digit PIN yang sama untuk verifikasi'
                          : 'PIN digunakan untuk mengamankan transaksi transfer Anda',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  else
                    PinKeypad(
                      pin: _isConfirming ? _confirmPin : _firstPin,
                      errorMessage: _errorMessage,
                      onDigitPressed: _onDigitPressed,
                      onDeletePressed: _onDeletePressed,
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
