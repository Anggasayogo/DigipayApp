import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../beneficiary/domain/entities/beneficiary_entity.dart';
import '../../../beneficiary/presentation/pages/saved_beneficiaries_page.dart';
import '../../../wallet/presentation/blocs/wallet_bloc.dart';
import '../../../wallet/presentation/blocs/wallet_state.dart';
import '../blocs/transfer_bloc.dart';
import '../blocs/transfer_state.dart';
import 'transfer_confirmation_sheet.dart';

class TransferInputPage extends StatefulWidget {
  final BeneficiaryEntity? initialBeneficiary;

  const TransferInputPage({super.key, this.initialBeneficiary});

  @override
  State<TransferInputPage> createState() => _TransferInputPageState();
}

class _TransferInputPageState extends State<TransferInputPage> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  BeneficiaryEntity? _beneficiary;
  int _amount = 0;
  static const int _fee = 6500;

  final List<int> _quickAmounts = [
    50000,
    100000,
    250000,
    500000,
    1000000,
    2000000,
  ];

  @override
  void initState() {
    super.initState();
    _beneficiary = widget.initialBeneficiary;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final parsed = CurrencyFormatter.parse(val).toInt();
    setState(() {
      _amount = parsed;
    });
  }

  void _selectQuickAmount(int val) {
    setState(() {
      _amount = val;
      _amountController.text = CurrencyFormatter.format(val).replaceAll('Rp ', '');
    });
  }

  void _proceedToConfirmation() {
    if (_beneficiary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih rekening penerima terlebih dahulu')),
      );
      return;
    }
    if (_amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal transfer adalah Rp 10.000')),
      );
      return;
    }
    if (_amount > 25000000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal transfer per transaksi Rp 25.000.000')),
      );
      return;
    }

    final wallet = context.read<WalletBloc>().state.wallet;
    final available = wallet?.availableBalance ?? 0;
    if (_amount + _fee > available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saldo tidak mencukupi. Dibutuhkan ${CurrencyFormatter.format(_amount + _fee)}, saldo tersedia: ${CurrencyFormatter.format(available)}',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransferConfirmationSheet(
        beneficiary: _beneficiary!,
        amount: _amount,
        fee: _fee,
        description: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransferBloc, TransferState>(
      listener: (context, state) {
        if (state.status == TransferStatus.success && state.latestTransfer != null) {
          context.pushReplacement('/transfer-result', extra: state.latestTransfer);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Transfer Uang'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Beneficiary Card
              const Text(
                'Rekening Penerima',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),

              if (_beneficiary != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _beneficiary!.bankCode.isNotEmpty
                                ? (_beneficiary!.bankCode.length > 4
                                    ? _beneficiary!.bankCode.substring(0, 4)
                                    : _beneficiary!.bankCode)
                                : 'BANK',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _beneficiary!.accountHolderName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_beneficiary!.bankName} • ${_beneficiary!.maskedAccountNumber ?? _beneficiary!.accountNumber}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final selected = await Navigator.push<BeneficiaryEntity>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SavedBeneficiariesPage(isSelectionMode: true),
                            ),
                          );
                          if (selected != null) {
                            setState(() => _beneficiary = selected);
                          }
                        },
                        child: const Text('Ganti', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              else
                InkWell(
                  onTap: () async {
                    final selected = await Navigator.push<BeneficiaryEntity>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedBeneficiariesPage(isSelectionMode: true),
                      ),
                    );
                    if (selected != null) {
                      setState(() => _beneficiary = selected);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4), style: BorderStyle.solid),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text(
                          'Pilih atau Tambah Rekening Tujuan',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Amount Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nominal Transfer',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        BlocBuilder<WalletBloc, WalletState>(
                          builder: (context, state) {
                            final bal = state.wallet?.availableBalance ?? 0;
                            return Text(
                              'Saldo: ${CurrencyFormatter.format(bal)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Rp',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                            ),
                            onChanged: _onAmountChanged,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Quick Nominal Pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickAmounts.map((q) {
                        final isSelected = _amount == q;
                        return InkWell(
                          onTap: () => _selectQuickAmount(q),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryLight : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              CurrencyFormatter.formatCompact(q),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Notes Input
              CustomTextField(
                controller: _notesController,
                label: 'Catatan / Berita Transfer (Opsional)',
                hint: 'Contoh: Bayar invoice katering',
                prefixIcon: Icons.edit_note_rounded,
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Fee Breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Nominal Transfer', CurrencyFormatter.format(_amount)),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Biaya Admin (Flat)', CurrencyFormatter.format(_fee)),
                    const Divider(height: 20),
                    _buildSummaryRow(
                      'Total Pendebetan',
                      CurrencyFormatter.format(_amount > 0 ? _amount + _fee : 0),
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Proceed Button
              CustomButton(
                text: 'Lanjutkan',
                icon: Icons.arrow_forward_rounded,
                onPressed: _proceedToConfirmation,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
