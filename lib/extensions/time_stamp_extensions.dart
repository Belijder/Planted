import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

extension TimestampFormatting on Timestamp {
  String toFormattedDateString() {
    // Convert the Timestamp to a DateTime
    DateTime dateTime = toDate();
    // Format the DateTime object as "dd MMM yyyy"
    return DateFormat('dd MMM yyyy').format(dateTime);
  }
}