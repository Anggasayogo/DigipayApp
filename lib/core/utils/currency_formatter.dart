import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(num? amount) {
    if (amount == null) return 'Rp 0';
    return _currencyFormat.format(amount);
  }

  static String formatCompact(num? amount) {
    if (amount == null) return 'Rp 0';
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)} M';
    }
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    }
    return _currencyFormat.format(amount);
  }

  static num parse(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    return num.tryParse(cleaned) ?? 0;
  }
}
