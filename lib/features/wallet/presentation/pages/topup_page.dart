import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../blocs/wallet_bloc.dart';
import '../blocs/wallet_event.dart';
import '../blocs/wallet_state.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  int _amount = 0;

  final List<int> _quickAmounts = [
    50000,
    100000,
    200000,
    500000,
    1000000,
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    setState(() {
      _amount = CurrencyFormatter.parse(val).toInt();
    });
  }

  void _selectQuick(int val) {
    setState(() {
      _amount = val;
      _amountController.text = CurrencyFormatter.format(val).replaceAll('Rp ', '');
    });
  }

  void _onTopup() {
    if (_amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal top up adalah Rp 10.000')),
      );
      return;
    }

    context.read<WalletBloc>().add(
          TopupSubmittedEvent(
            amount: _amount,
            description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state.isTopupSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Top up saldo berhasil!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        } else if (state.status == WalletStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == WalletStatus.loading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Isi Saldo (Top Up)'),
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
                // Current Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saldo Tersedia Saat Ini', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          SizedBox(height: 4),
                        ],
                      ),
                      Text(
                        CurrencyFormatter.format(state.wallet?.availableBalance ?? 0),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Amount Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Nominal Top Up',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 14),

                      // Quick Pills
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _quickAmounts.map((q) {
                          final isSelected = _amount == q;
                          return InkWell(
                            onTap: () => _selectQuick(q),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryLight : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                CurrencyFormatter.format(q),
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
                      const SizedBox(height: 20),

                      const Text(
                        'Atau Masukkan Nominal Sendiri',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: 'Min Rp 10.000',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(14),
                            child: Text('Rp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: _onAmountChanged,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                CustomTextField(
                  controller: _descController,
                  label: 'Catatan (Opsional)',
                  hint: 'Contoh: Topup dompet harian',
                  prefixIcon: Icons.notes_rounded,
                ),

                const SizedBox(height: 32),

                // Top Up Button
                CustomButton(
                  text: 'Isi Saldo Sekarang',
                  isLoading: isLoading,
                  icon: Icons.account_balance_wallet_rounded,
                  onPressed: _onTopup,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
