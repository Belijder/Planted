import 'package:url_launcher/url_launcher.dart';

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

void sendEmailToOwner() {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'plantedsharenature@gmail.com',
    query: encodeQueryParameters(<String, String>{
      'subject': 'W czym możemy pomóc?',
    }),
  );

  launchUrl(emailLaunchUri);
}
