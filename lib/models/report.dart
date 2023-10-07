import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String reportID;
  final String reportingPersonID;
  final String reportedPersonID;
  final String reportedPersonDisplayName;
  final String conversationID;
  final String announcementID;
  final String reasonForReporting;
  final String additionalInformation;
  final int status;
  final String adminResponse;
  final Timestamp reportingDate;

  Report({
    required this.reportID,
    required this.reportingPersonID,
    required this.reportedPersonID,
    required this.reportedPersonDisplayName,
    required this.conversationID,
    required this.announcementID,
    required this.reasonForReporting,
    required this.additionalInformation,
    required this.status,
    required this.adminResponse,
    required this.reportingDate,
  });

  String get statusDescription =>
      status == 0 ? 'Czeka na weryfikację' : 'Zweryfikowano';

  String get decision {
    switch (status) {
      case 1:
        return 'Przyjęto zgłoszenie';
      case 2:
        return 'Odrzucono zgłoszenie';
      default:
        return '';
    }
  }

  factory Report.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Report(
      reportID: snapshot.id,
      reportingPersonID: data['reportingPersonID'],
      reportedPersonID: data['reportedPersonID'],
      reportedPersonDisplayName: data['reportedPersonDisplayName'],
      conversationID: data['conversationID'],
      announcementID: data['announcementID'],
      reasonForReporting: data['reasonForReporting'],
      additionalInformation: data['additionalInformation'],
      status: data['status'],
      adminResponse: data['adminResponse'],
      reportingDate: data['reportingDate'],
    );
  }
}
