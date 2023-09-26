import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';

String formatTimestamp(Timestamp timestamp) {
  initializeDateFormatting();
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));

  final dateTime = timestamp.toDate(); // Convert Timestamp to DateTime

  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    // Same day, return hours and minutes
    return DateFormat.Hm().format(dateTime);
  } else if (dateTime.year == yesterday.year &&
      dateTime.month == yesterday.month &&
      dateTime.day == yesterday.day) {
    // Yesterday
    return 'Wczoraj';
  } else if (dateTime.isAfter(now.subtract(const Duration(days: 7)))) {
    // Within the last 7 days, return the day name
    return DateFormat('EEEE', 'pl_PL').format(dateTime);
  } else {
    // More than 7 days ago, return DD.MM.YYYY
    return DateFormat('dd.MM.yyyy', 'pl_PL').format(dateTime);
  }
}
