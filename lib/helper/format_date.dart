// Formatting Date
import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(DateTime date) {
    final formatDate = DateFormat('dd/MM/yyyy');
    return formatDate.format(date);
  }
}
