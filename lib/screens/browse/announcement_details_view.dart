import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/images.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/styles/box_decoration_styles.dart';
import 'package:planted/styles/buttons_styles.dart';
import 'package:planted/styles/text_styles.dart';

enum ModalPopupAction { report, block }

class AnnouncementDetailsView extends StatelessWidget {
  final Announcement announcement;
  const AnnouncementDetailsView({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorEggsheel,
        leading: IconButton(
          onPressed: () {
            context
                .read<BrowseScreenBloc>()
                .add(const BrowseScreenEventGoToListView());
          },
          icon: const Icon(Icons.arrow_back),
          color: colorSepia,
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppBarTitleText.announcementDetails,
            style: TextStyles.titleTextStyle(weight: FontWeight.bold),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton.filled(
              onPressed: () {
                context
                    .read<BrowseScreenBloc>()
                    .add(BrowseScreenEventGoToConversationView(
                      announcement: announcement,
                    ));
              },
              style: IconButton.styleFrom(
                backgroundColor: listTileBackground,
                elevation: 4,
                shadowColor: colorSepia.withAlpha(50),
              ),
              icon: const Icon(Icons.textsms_outlined),
              color: colorDarkMossGreen,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: backgroundBoxDecoration,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width - 32,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: announcement.imageURL,
                      placeholder: (context, url) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: backgroundBoxDecoration,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.name,
                        style: TextStyles.largeTitleTextStyle(
                            weight: FontWeight.bold),
                      ),
                      announcement.latinName.isNotEmpty
                          ? Text(
                              announcement.latinName,
                              style: TextStyles.titleTextStyle(
                                  weight: FontWeight.w200),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: backgroundBoxDecoration,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    announcement.description.isNotEmpty
                        ? announcement.description
                        : CustomText.noAdditionalDescription,
                    style: TextStyles.bodyTextStyle(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: backgroundBoxDecoration,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CustomText.seedlingsNumber,
                        style: TextStyles.headlineTextStyle(
                            weight: FontWeight.bold),
                      ),
                      Text(
                        '${announcement.seedCount}',
                        style: TextStyles.headlineTextStyle(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: backgroundBoxDecoration,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CustomText.pickupLocation,
                        style: TextStyles.headlineTextStyle(
                            weight: FontWeight.bold),
                      ),
                      Text(
                        announcement.city,
                        style: TextStyles.headlineTextStyle(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: backgroundBoxDecoration,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CustomText.addedBy,
                        style: TextStyles.headlineTextStyle(
                            weight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          showCupertinoModalPopup<ModalPopupAction>(
                            context: context,
                            builder: (context) {
                              return Container(
                                decoration: cupertinoModalPopapBoxDecoration,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 20, left: 20, right: 20, top: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: double.infinity - 40,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor:
                                                colorRedKenyanCopper,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(ModalPopupAction.report);
                                          },
                                          child: const Text(
                                              ButtonLabelText.reportUser),
                                        ),
                                      ),
                                      SizedBox(
                                        width: double.infinity - 40,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor:
                                                colorRedKenyanCopper,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(ModalPopupAction.block);
                                          },
                                          child: const Text(
                                              ButtonLabelText.blockUser),
                                        ),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                              ButtonLabelText.cancel),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ).then((value) {
                            if (value != null) {
                              switch (value) {
                                case ModalPopupAction.report:
                                  context.read<BrowseScreenBloc>().add(
                                          BrowseScreenEventGoToReportViewFromAnnouncement(
                                        announcement: announcement,
                                      ));
                                case ModalPopupAction.block:
                                  context.read<BrowseScreenBloc>().add(
                                      BrowseScreenEventBlockUserFromDetailsView(
                                          announcement: announcement,
                                          userToBlockID: announcement.giverID));
                              }
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 26,
                              width: 26,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: CachedNetworkImage(
                                  fadeInDuration: Duration.zero,
                                  fadeOutDuration: Duration.zero,
                                  placeholder: (context, url) =>
                                      Image.asset(ImageName.personPlaceholder),
                                  imageUrl: announcement.giverPhotoURL,
                                  errorWidget: (context, _, __) =>
                                      Image.asset(ImageName.personPlaceholder),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              announcement.giverDisplayName,
                              style: TextStyles.headlineTextStyle(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: filledButtonStyle,
                  onPressed: () {
                    context
                        .read<BrowseScreenBloc>()
                        .add(BrowseScreenEventGoToConversationView(
                          announcement: announcement,
                        ));
                  },
                  child: const Text(ButtonLabelText.sendMessage),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
