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
  });

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
    );
  }
}
