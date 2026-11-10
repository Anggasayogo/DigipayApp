import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/bank_entity.dart';
import '../blocs/beneficiary_bloc.dart';
import '../blocs/beneficiary_event.dart';
import '../blocs/beneficiary_state.dart';
import 'bank_picker_sheet.dart';

class CheckAccountPage extends StatefulWidget {
  const CheckAccountPage({super.key});

  @override
  State<CheckAccountPage> createState() => _CheckAccountPageState();
}

class _CheckAccountPageState extends State<CheckAccountPage> {
  final _accountController = TextEditingController();
  BankEntity? _selectedBank;

  @override
  void initState() {
    super.initState();
    context.read<BeneficiaryBloc>().add(FetchBanksEvent());
    context.read<BeneficiaryBloc>().add(ResetCheckAccountEvent());
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  void _onCheckAccount() {
    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bank tujuan terlebih dahulu')),
      );
      return;
    }
    final acc = _accountController.text.trim();
    if (acc.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor rekening minimal 5 digit')),
      );
      return;
    }

    context.read<BeneficiaryBloc>().add(
          CheckAccountEvent(
            bankId: _selectedBank!.id,
            accountNumber: acc,
          ),
        );
  }

  void _onSaveAccount() {
    if (_selectedBank != null && _accountController.text.isNotEmpty) {
      context.read<BeneficiaryBloc>().add(
            SaveBeneficiaryEvent(
              bankId: _selectedBank!.id,
              accountNumber: _accountController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BeneficiaryBloc, BeneficiaryState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final checkedAccount = state.checkedAccount;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Cek & Simpan Rekening'),
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
                // Info Banner
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Validasi Penerima',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Pastikan nomor rekening terdaftar di bank tujuan sebelum transfer',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bank Selector
                const Text(
                  'Bank Tujuan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => BankPickerSheet(
                        banks: state.banks,
                        selectedBank: _selectedBank,
                        onBankSelected: (bank) {
                          setState(() => _selectedBank = bank);
                          context.read<BeneficiaryBloc>().add(ResetCheckAccountEvent());
                        },
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_rounded, color: AppColors.textMuted, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedBank != null
                                ? '${_selectedBank!.name} (${_selectedBank!.code})'
                                : 'Pilih Bank Tujuan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _selectedBank != null ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Account Number Input
                CustomTextField(
                  controller: _accountController,
                  label: 'Nomor Rekening',
                  hint: 'Contoh: 1234567890',
                  prefixIcon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) {
                    if (checkedAccount != null) {
                      context.read<BeneficiaryBloc>().add(ResetCheckAccountEvent());
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Check Button
                CustomButton(
                  text: 'Periksa Rekening',
                  isLoading: state.isChecking,
                  icon: Icons.search_rounded,
                  onPressed: _onCheckAccount,
                ),

                // Result Card if verified
                if (checkedAccount != null) ...[
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.success, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.successLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Rekening Terverifikasi!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildDetailRow('Nama Pemilik', checkedAccount.accountHolderName, isBold: true),
                        _buildDetailRow('Bank', checkedAccount.bankName),
                        _buildDetailRow('Nomor Rekening', checkedAccount.accountNumber),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Simpan',
                                isOutlined: true,
                                isLoading: state.isSaving,
                                icon: Icons.bookmark_add_outlined,
                                onPressed: _onSaveAccount,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: 'Transfer',
                                icon: Icons.send_rounded,
                                onPressed: () {
                                  context.push(
                                    '/transfer-input',
                                    extra: checkedAccount,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
