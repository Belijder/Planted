import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

extension TimestampFormatting on Timestamp {
  String toFormattedDateString() {
    DateTime dateTime = toDate();
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }
}

extension TimestampComparison on Timestamp {
  bool isEarlierThan(Timestamp other) {
    final thisDateTime = toDate();
    final otherDateTime = other.toDate();
    return thisDateTime.isBefore(otherDateTime);
  }

  bool isLaterThan(Timestamp other) {
    final thisDateTime = toDate();
    final otherDateTime = other.toDate();
    return thisDateTime.isAfter(otherDateTime);
  }
}
