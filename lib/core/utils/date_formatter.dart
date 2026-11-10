import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(dynamic date) {
    if (date == null) return '-';
    DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else {
      return '-';
    }

    final local = dateTime.toLocal();
    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(local);
    } catch (_) {
      try {
        return DateFormat('dd MMM yyyy, HH:mm').format(local);
      } catch (_) {
        return local.toString();
      }
    }
  }

  static String formatDate(dynamic date) {
    if (date == null) return '-';
    DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else {
      return '-';
    }

    final local = dateTime.toLocal();
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(local);
    } catch (_) {
      try {
        return DateFormat('dd MMMM yyyy').format(local);
      } catch (_) {
        return local.toString();
      }
    }
  }

  static String formatTime(dynamic date) {
    if (date == null) return '-';
    DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else {
      return '-';
    }

    final local = dateTime.toLocal();
    try {
      return DateFormat('HH:mm:ss', 'id_ID').format(local);
    } catch (_) {
      return '${local.hour}:${local.minute}:${local.second}';
    }
  }
}
