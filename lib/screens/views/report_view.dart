import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/helpers/create_input_decoration.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/styles/buttons_styles.dart';
import 'package:planted/styles/text_styles.dart';
import 'package:planted/utilities/dialogs/show_information_dialog.dart';

typedef ReturnAction = void Function({
  required Announcement announcement,
  required Conversation? conversation,
  required String userID,
});

typedef ReportAction = void Function({
  required Announcement announcement,
  required Conversation? conversation,
  required String userID,
  required String reasonForReporting,
  required String additionalInformation,
});

final listOfReportReasons = [
  'Niewłaściwe treści',
  'Obraźliwy kontent',
  'Niekulturalne wypowiedzi',
  'Inny'
];

class ReportView extends HookWidget {
  const ReportView({
    super.key,
    required this.announcement,
    required this.conversation,
    required this.userID,
    required this.returnAction,
    required this.reportAction,
  });
  final Announcement announcement;
  final Conversation? conversation;
  final String userID;
  final ReturnAction returnAction;
  final ReportAction reportAction;

  String get personDisplayName {
    if (conversation == null) {
      return announcement.giverDisplayName;
    } else {
      return (userID == conversation!.giver)
          ? conversation!.takerDisplayName
          : conversation!.giverDisplayName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<String?> dropdownValueState =
        useState(listOfReportReasons.first);

    final otherReasonTextController = useTextEditingController();
    final additionalInformationTextController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorEggsheel,
        leading: IconButton(
          onPressed: () {
            returnAction(
              announcement: announcement,
              conversation: conversation,
              userID: userID,
            );
          },
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            shadowColor: colorSepia.withAlpha(50),
          ),
          color: colorSepia,
        ),
        title: const Text(
          'Zgłoś użytkownika',
          style: TextStyle(
              color: colorSepia, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Zgłoszenie dotyczące użytkownika:',
                style: textStyle15BoldSepia,
              ),
              const SizedBox(height: 5),
              Text(
                personDisplayName,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: colorRedKenyanCopper,
                ),
              ),
              const SizedBox(height: 50),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Powód:',
                    style: textStyle15BoldSepia,
                  ),
                  DropdownButton<String>(
                    value: dropdownValueState.value,
                    icon: const Icon(
                      Icons.arrow_drop_down_outlined,
                      color: colorSepia,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    dropdownColor: listTileBackground,
                    elevation: 16,
                    style: const TextStyle(
                      color: colorRedKenyanCopper,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    underline: Container(height: 2, color: colorSepia),
                    onChanged: (String? value) {
                      dropdownValueState.value = value;
                    },
                    items: listOfReportReasons
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (dropdownValueState.value == 'Inny')
                Column(
                  children: [
                    TextField(
                      controller: otherReasonTextController,
                      decoration: createInputDecoration(label: 'Podaj powód'),
                      style: textStyle15BoldSepia,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      textCapitalization: TextCapitalization.sentences,
                      enableSuggestions: false,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              SizedBox(
                height: 150,
                child: TextField(
                  controller: additionalInformationTextController,
                  decoration:
                      createInputDecoration(label: 'Dodatkowe informacje'),
                  style: textStyle15BoldSepia,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  minLines: null,
                  maxLines: null,
                  expands: true,
                  textCapitalization: TextCapitalization.sentences,
                  enableSuggestions: false,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: createFilledButtonStyle(
                      backgroundColor: colorRedKenyanCopper),
                  onPressed: () {
                    if (dropdownValueState.value == 'Inny' &&
                        otherReasonTextController.text.trim().isEmpty) {
                      showInformationDialog(
                        context: context,
                        title: 'Podaj powód zgłoszenia',
                        content:
                            'Aby wysłać zgłoszenie musisz podać powód zgłoszenia.',
                      );
                      return;
                    }
                    reportAction(
                        announcement: announcement,
                        conversation: conversation,
                        userID: userID,
                        reasonForReporting: dropdownValueState.value ?? '',
                        additionalInformation:
                            additionalInformationTextController.text);
                  },
                  child: const Text('Dodaj Zgłoszenie'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
