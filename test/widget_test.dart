import 'package:flutter_test/flutter_test.dart';
import 'package:digipay/core/constants/app_colors.dart';
import 'package:digipay/core/utils/currency_formatter.dart';

void main() {
  test('Currency formatter formats Indonesian Rupiah correctly', () {
    expect(CurrencyFormatter.format(10000000), 'Rp 10.000.000');
    expect(CurrencyFormatter.format(50000), 'Rp 50.000');
    expect(CurrencyFormatter.format(0), 'Rp 0');
  });

  test('App primary colors are red theme', () {
    expect(AppColors.primary.toARGB32(), 0xFFD32F2F);
  });
}
