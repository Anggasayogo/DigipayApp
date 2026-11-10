import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/beneficiary_entity.dart';
import '../blocs/beneficiary_bloc.dart';
import '../blocs/beneficiary_event.dart';
import '../blocs/beneficiary_state.dart';

class SavedBeneficiariesPage extends StatefulWidget {
  final bool isSelectionMode;

  const SavedBeneficiariesPage({
    super.key,
    this.isSelectionMode = false,
  });

  @override
  State<SavedBeneficiariesPage> createState() => _SavedBeneficiariesPageState();
}

class _SavedBeneficiariesPageState extends State<SavedBeneficiariesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<BeneficiaryBloc>().add(FetchBeneficiariesEvent());
    context.read<BeneficiaryBloc>().add(FetchBanksEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isSelectionMode ? 'Pilih Penerima Transfer' : 'Daftar Rekening Tersimpan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
            tooltip: 'Tambah / Cek Rekening Baru',
            onPressed: () => context.push('/check-account'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Semua Rekening'),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                  SizedBox(width: 6),
                  Text('Favorit'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama penerima atau nomor rekening...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onChanged: (val) => setState(() => _search = val.toLowerCase()),
            ),
          ),

          // Tab Views
          Expanded(
            child: BlocBuilder<BeneficiaryBloc, BeneficiaryState>(
              builder: (context, state) {
                if (state.status == BeneficiaryStatus.loading && state.beneficiaries.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // All Beneficiaries Tab
                    _buildBeneficiaryList(
                      state.beneficiaries.where((b) {
                        return b.accountHolderName.toLowerCase().contains(_search) ||
                            b.accountNumber.contains(_search) ||
                            b.bankName.toLowerCase().contains(_search);
                      }).toList(),
                    ),
                    // Favorites Tab
                    _buildBeneficiaryList(
                      state.favoriteBeneficiaries.where((b) {
                        return b.accountHolderName.toLowerCase().contains(_search) ||
                            b.accountNumber.contains(_search) ||
                            b.bankName.toLowerCase().contains(_search);
                      }).toList(),
                      isFavoriteTab: true,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Rekening Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => context.push('/check-account'),
      ),
    );
  }

  Widget _buildBeneficiaryList(List<BeneficiaryEntity> list, {bool isFavoriteTab = false}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFavoriteTab ? Icons.star_border_rounded : Icons.contacts_outlined,
              size: 56,
              color: AppColors.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              isFavoriteTab ? 'Belum ada rekening favorit' : 'Belum ada rekening tersimpan',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              isFavoriteTab
                  ? 'Ketuk tanda bintang pada rekening untuk menjadikannya favorit'
                  : 'Gunakan tombol + untuk menambah dan mengecek rekening',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final ben = list[index];

        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              if (widget.isSelectionMode) {
                context.pop(ben);
              } else {
                context.push('/transfer-input', extra: ben);
              }
            },
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  ben.bankCode.isNotEmpty
                      ? (ben.bankCode.length > 4 ? ben.bankCode.substring(0, 4) : ben.bankCode)
                      : 'BANK',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
            title: Text(
              ben.accountHolderName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  '${ben.bankName} • ${ben.maskedAccountNumber ?? ben.accountNumber}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                ben.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: ben.isFavorite ? Colors.amber : AppColors.textMuted,
                size: 26,
              ),
              onPressed: () {
                context.read<BeneficiaryBloc>().add(ToggleFavoriteBeneficiaryEvent(ben.id));
              },
            ),
          ),
        );
      },
    );
  }
}
