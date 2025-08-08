import 'package:intl/intl.dart';

class Helpers {
  static String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    var date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd – HH:mm').format(date);
  }

  static String? validateEmail(String? value) {
    if (value == null || !value.contains('@')) {
      return 'Please enter a valid email.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }
}
