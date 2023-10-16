import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_event.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/enums.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/styles/create_input_decoration.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/styles/buttons_styles.dart';
import 'package:planted/styles/text_styles.dart';
import 'package:planted/utilities/dialogs/show_information_dialog.dart';

final listOfReportReasons = [
  ReportReason.inappropriateContent,
  ReportReason.offensiveContent,
  ReportReason.immoralStatements,
  ReportReason.other,
];

class ReportView extends HookWidget {
  const ReportView({
    super.key,
    required this.announcement,
    required this.conversation,
    required this.userID,
    required this.parentScreen,
  });
  final Announcement announcement;
  final Conversation? conversation;
  final String userID;
  final ParentScreen parentScreen;

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
            returnAction(context);
          },
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            shadowColor: colorSepia.withAlpha(50),
          ),
          color: colorSepia,
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            CustomText.reportUser,
            style: TextStyle(
                color: colorSepia, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                CustomText.appliesToUser,
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
                    CustomText.reportReason,
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
              if (dropdownValueState.value == ReportReason.other)
                Column(
                  children: [
                    TextField(
                      controller: otherReasonTextController,
                      decoration:
                          createInputDecoration(label: CustomText.giveReason),
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
                      createInputDecoration(label: CustomText.additionalInfo),
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
                    if (dropdownValueState.value == ReportReason.other &&
                        otherReasonTextController.text.trim().isEmpty) {
                      showInformationDialog(
                        context: context,
                        title: DialogTitleText.reportReasonRequired,
                        content: DialogContentText.reportReasonRequired,
                      );
                      return;
                    }
                    reportAction(
                        context: context,
                        reasonForReporting: dropdownValueState.value ?? '',
                        additionalInformation:
                            additionalInformationTextController.text);
                  },
                  child: const Text(ButtonLabelText.addReport),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void returnAction(BuildContext context) {
    switch (parentScreen) {
      case ParentScreen.browseScreen:
        if (conversation != null) {
          context
              .read<BrowseScreenBloc>()
              .add(BrowseScreenEventGoToConversationView(
                announcement: announcement,
              ));
        } else {
          context.read<BrowseScreenBloc>().add(BrowseScreenEventGoToDetailView(
                announcement: announcement,
              ));
        }
      case ParentScreen.messagesScreen:
        if (conversation != null) {
          context
              .read<MessagesScreenBloc>()
              .add(MessagesScreenEventBackToConversationFromReportView(
                conversation: conversation!,
                announcement: announcement,
              ));
        } else {
          context
              .read<MessagesScreenBloc>()
              .add(MessagesScreenEventGoToListOfConvesations(
                announcement: announcement,
              ));
        }
    }
  }

  void reportAction({
    required BuildContext context,
    required String reasonForReporting,
    required String additionalInformation,
  }) {
    switch (parentScreen) {
      case ParentScreen.browseScreen:
        context.read<BrowseScreenBloc>().add(BrowseScreenEventSendReport(
              announcement: announcement,
              conversation: conversation,
              userID: userID,
              reasonForReporting: reasonForReporting,
              additionalInformation: additionalInformation,
            ));
      case ParentScreen.messagesScreen:
        context.read<MessagesScreenBloc>().add(MessagesScreenEventSendReport(
              announcement: announcement,
              conversation: conversation,
              userID: userID,
              reasonForReporting: reasonForReporting,
              additionalInformation: additionalInformation,
            ));
    }
  }
}
