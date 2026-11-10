import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../wallet/presentation/blocs/wallet_bloc.dart';
import '../../../wallet/presentation/blocs/wallet_event.dart';
import '../../domain/entities/transfer_entity.dart';
import '../blocs/transfer_bloc.dart';
import '../blocs/transfer_event.dart';

class TransferResultPage extends StatefulWidget {
  final TransferEntity transfer;

  const TransferResultPage({super.key, required this.transfer});

  @override
  State<TransferResultPage> createState() => _TransferResultPageState();
}

class _TransferResultPageState extends State<TransferResultPage> {
  late TransferEntity _transfer;
  bool _isRefreshing = false;
  Timer? _pollingTimer;
  int _pollCount = 0;
  static const int _maxPolls = 6; // Poll up to ~18 seconds

  @override
  void initState() {
    super.initState();
    _transfer = widget.transfer;

    // If transfer is still processing, start smart auto-polling
    if (!_transfer.isSuccess && !_transfer.isFailed) {
      _startAutoPolling();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startAutoPolling() {
    _pollingTimer?.cancel();
    _pollCount = 0;
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _pollCount++;
      if (_pollCount > _maxPolls || !mounted) {
        timer.cancel();
        return;
      }
      await _fetchLatestStatus(isAuto: true);
      if (_transfer.isSuccess || _transfer.isFailed) {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchLatestStatus({bool isAuto = false}) async {
    if (_isRefreshing && !isAuto) return;

    if (!isAuto) {
      setState(() => _isRefreshing = true);
    }

    try {
      final transferBloc = context.read<TransferBloc>();
      final updated = await transferBloc.transferRepository.getTransferById(_transfer.id);

      if (!mounted) return;

      final previousStatus = _transfer.status;
      setState(() {
        _transfer = updated;
        _isRefreshing = false;
      });

      // Update Bloc internal state & history
      transferBloc.add(FetchTransferDetailEvent(updated.id));

      // If status changed or user manually refreshed, sync wallet balance
      if (updated.isSuccess) {
        context.read<WalletBloc>().add(const FetchBalanceEvent(isSilent: true));
      }

      if (!isAuto) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (updated.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('Status transaksi: BERHASIL!'),
            ),
          );
        } else if (updated.isFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text('Status transaksi: GAGAL - ${updated.failureReason ?? "Ditolak bank"}'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.info,
              content: Text('Status transaksi masih dalam antrean proses...'),
            ),
          );
        }
      } else if (previousStatus != updated.status && (updated.isSuccess || updated.isFailed)) {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRefreshing = false);
      if (!isAuto) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Gagal memperbarui status: ${e.toString().replaceAll("Exception: ", "")}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusSubtitle;

    if (_transfer.isSuccess) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_rounded;
      statusTitle = 'Transfer Berhasil!';
      statusSubtitle = 'Dana telah berhasil dikirim ke rekening penerima.';
    } else if (_transfer.isFailed) {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel_rounded;
      statusTitle = 'Transfer Gagal';
      statusSubtitle = _transfer.failureReason ?? 'Rekening tidak valid atau bank tujuan menolak transaksi.';
    } else {
      statusColor = AppColors.warning;
      statusIcon = Icons.hourglass_top_rounded;
      statusTitle = 'Transfer Sedang Diproses';
      statusSubtitle = 'Sistem sedang memproses transaksi pencairan dana ke bank tujuan.';
    }

    final isPendingOrProcessing = !_transfer.isSuccess && !_transfer.isFailed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Bukti Transaksi'),
        actions: [
          IconButton(
            tooltip: 'Perbarui Status',
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isRefreshing ? null : () => _fetchLatestStatus(isAuto: false),
          ),
          IconButton(
            tooltip: 'Tutup',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _fetchLatestStatus(isAuto: false),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Status Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statusSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      CurrencyFormatter.format(_transfer.totalAmount),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Status Badge Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPendingOrProcessing) ...[
                            SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            _transfer.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dedicated Refresh Button inside Card for Processing status
                    if (isPendingOrProcessing) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _isRefreshing ? null : () => _fetchLatestStatus(isAuto: false),
                        icon: _isRefreshing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              )
                            : const Icon(Icons.sync_rounded, size: 18),
                        label: Text(_isRefreshing ? 'Memeriksa...' : 'Perbarui Status Transaksi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Receipt Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rincian Transaksi',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const Divider(height: 20),

                    // Reference No with Copy Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('No. Referensi', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Row(
                          children: [
                            Text(
                              _transfer.referenceNo,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: _transfer.referenceNo));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No. Referensi disalin!')),
                                );
                              },
                              child: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    _buildReceiptRow('Waktu Transaksi', DateFormatter.formatDateTime(_transfer.createdAt)),
                    const SizedBox(height: 10),
                    _buildReceiptRow('Penerima', _transfer.recipientName),
                    const SizedBox(height: 10),
                    _buildReceiptRow('Bank Tujuan', _transfer.recipientBank),
                    const SizedBox(height: 10),
                    _buildReceiptRow('Nomor Rekening', _transfer.recipientAccount),
                    if (_transfer.description != null && _transfer.description!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildReceiptRow('Berita Transfer', _transfer.description!),
                    ],

                    const Divider(height: 24),
                    _buildReceiptRow('Nominal Transfer', CurrencyFormatter.format(_transfer.amount)),
                    const SizedBox(height: 8),
                    _buildReceiptRow('Biaya Admin', CurrencyFormatter.format(_transfer.fee)),
                    const Divider(height: 20),
                    _buildReceiptRow(
                      'Total Pendebetan',
                      CurrencyFormatter.format(_transfer.totalAmount),
                      isBold: true,
                      isHighlight: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              if (isPendingOrProcessing) ...[
                CustomButton(
                  text: 'Cek Status Sekarang',
                  icon: Icons.refresh_rounded,
                  isLoading: _isRefreshing,
                  onPressed: () => _fetchLatestStatus(isAuto: false),
                ),
                const SizedBox(height: 12),
              ],

              CustomButton(
                text: 'Kembali ke Beranda',
                isOutlined: isPendingOrProcessing,
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Lihat Riwayat Transaksi',
                isOutlined: true,
                onPressed: () => context.push('/history'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
