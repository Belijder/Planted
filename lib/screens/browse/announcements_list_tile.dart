import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/images.dart';
import 'package:planted/extensions/time_stamp_extensions.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/styles/box_decoration_styles.dart';

class AnnouncementListTile extends StatelessWidget {
  const AnnouncementListTile({
    super.key,
    required this.announcement,
  });

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: backgroundBoxDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: colorSepia,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        Text(
                          announcement.latinName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: colorSepia,
                              fontWeight: FontWeight.w300,
                              fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    announcement.timeStamp.toFormattedDateString(),
                    style: const TextStyle(
                        color: colorSepia,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: announcement.imageURL,
                    child: Container(
                        height: 130,
                        width: 130,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorDarkMossGreen, // Border color
                            width: 1.0, // Border width
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Builder(builder: (context) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(19.0),
                            child: CachedNetworkImage(
                              imageUrl: announcement.imageURL,
                              placeholder: (context, url) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              fit: BoxFit.cover,
                            ),
                          );
                        })),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 130,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                announcement.description.isNotEmpty
                                    ? announcement.description
                                    : 'Brak dodatkowego opisu.',
                                maxLines: 4,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: colorSepia,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Text(
                                    'Liczba sadzonek: ',
                                    style: TextStyle(
                                        color: colorSepia,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                  Text(
                                    '${announcement.seedCount}',
                                    style: const TextStyle(
                                        color: colorSepia, fontSize: 10),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Text(
                                    'Odbiór: ',
                                    style: TextStyle(
                                        color: colorSepia,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                  Text(
                                    announcement.city,
                                    style: const TextStyle(
                                        color: colorSepia, fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 26,
                                width: 26,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: CachedNetworkImage(
                                    fadeInDuration: Duration.zero,
                                    fadeOutDuration: Duration.zero,
                                    placeholder: (context, url) =>
                                        Image.asset(personPlaceholder),
                                    imageUrl: announcement.giverPhotoURL,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                announcement.giverDisplayName,
                                style: const TextStyle(
                                    color: colorSepia,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
