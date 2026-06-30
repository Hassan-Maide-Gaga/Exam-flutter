import 'package:intl/intl.dart';

class Formatters {
  static String formatPhone(String phone) {
    // Format: +221 77 123 45 67
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.length == 12 && cleaned.startsWith('+221')) {
      return '+${cleaned.substring(1, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9, 11)} ${cleaned.substring(11, 13)}';
    }
    return phone;
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'fr_SN',
      symbol: 'XOF ',
      decimalDigits: 0,
    ).format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}