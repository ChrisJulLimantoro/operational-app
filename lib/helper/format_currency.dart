// Formatting Currency
import 'package:intl/intl.dart';

class CurrencyHelper {
  static String formatRupiah(double amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 2,
    );
    return formatCurrency.format(amount);
  }
}
