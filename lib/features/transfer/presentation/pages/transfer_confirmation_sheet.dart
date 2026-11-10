import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/pin_keypad.dart';
import '../../../beneficiary/domain/entities/beneficiary_entity.dart';
import '../../../wallet/presentation/blocs/wallet_bloc.dart';
import '../../../wallet/presentation/blocs/wallet_event.dart';
import '../blocs/transfer_bloc.dart';
import '../blocs/transfer_event.dart';
import '../blocs/transfer_state.dart';

class TransferConfirmationSheet extends StatefulWidget {
  final BeneficiaryEntity beneficiary;
  final int amount;
  final int fee;
  final String? description;

  const TransferConfirmationSheet({
    super.key,
    required this.beneficiary,
    required this.amount,
    required this.fee,
    this.description,
  });

  @override
  State<TransferConfirmationSheet> createState() => _TransferConfirmationSheetState();
}

class _TransferConfirmationSheetState extends State<TransferConfirmationSheet> {
  bool _isEnteringPin = false;
  String _pin = '';
  String? _pinError;

  void _onDigitPressed(String digit) {
    if (_pin.length < 6) {
      setState(() {
        _pin += digit;
        _pinError = null;
      });

      if (_pin.length == 6) {
        _submitTransfer();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _pinError = null;
      });
    }
  }

  void _submitTransfer() {
    context.read<TransferBloc>().add(
          CreateTransferEvent(
            beneficiaryId: widget.beneficiary.id,
            amount: widget.amount,
            pin: _pin,
            description: widget.description,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransferBloc, TransferState>(
      listener: (context, state) {
        if (state.status == TransferStatus.error && state.errorMessage != null) {
          setState(() {
            _pinError = state.errorMessage;
            _pin = '';
          });
        } else if (state.status == TransferStatus.success) {
          // Refresh wallet balance silently
          context.read<WalletBloc>().add(const FetchBalanceEvent(isSilent: true));
          Navigator.of(context).pop(); // Close sheet; input page listener handles navigation
        }
      },
      builder: (context, state) {
        final isLoading = state.status == TransferStatus.loading;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * (_isEnteringPin ? 0.88 : 0.65),
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              if (!_isEnteringPin) ...[
                // Step 1: Transfer Confirmation Overview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Text(
                        'Konfirmasi Transfer',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Recipient Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Penerima',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.beneficiary.accountHolderName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(
                              '${widget.beneficiary.bankName} • ${widget.beneficiary.maskedAccountNumber ?? widget.beneficiary.accountNumber}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Detail breakdown
                      _buildRow('Nominal Transfer', CurrencyFormatter.format(widget.amount)),
                      const SizedBox(height: 12),
                      _buildRow('Biaya Admin', CurrencyFormatter.format(widget.fee)),
                      if (widget.description != null) ...[
                        const SizedBox(height: 12),
                        _buildRow('Catatan', widget.description!),
                      ],
                      const Divider(height: 24),
                      _buildRow(
                        'Total Pendebetan',
                        CurrencyFormatter.format(widget.amount + widget.fee),
                        isBold: true,
                        isPrimary: true,
                      ),
                      const SizedBox(height: 28),

                      // Confirm & Enter PIN Button
                      ElevatedButton(
                        onPressed: () => setState(() => _isEnteringPin = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline_rounded, size: 20, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Konfirmasi & Masukkan PIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Step 2: PIN Pad Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        onPressed: () => setState(() {
                          _isEnteringPin = false;
                          _pin = '';
                          _pinError = null;
                        }),
                      ),
                      const Text(
                        'Masukkan PIN Transaksi',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Transfer ${CurrencyFormatter.format(widget.amount + widget.fee)} ke ${widget.beneficiary.accountHolderName}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'Memproses transfer ke bank tujuan...',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          PinKeypad(
                            pin: _pin,
                            errorMessage: _pinError,
                            onDigitPressed: _onDigitPressed,
                            onDeletePressed: _onDeletePressed,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, bool isPrimary = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isPrimary ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
