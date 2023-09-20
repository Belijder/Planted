import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/images.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/styles/box_decoration_styles.dart';
import 'package:planted/styles/buttons_styles.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final Announcement announcement;
  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorEggsheel,
        leading: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              shadowColor: colorSepia.withAlpha(50),
            ),
            color: colorSepia,
          ),
        ),
        title: const Text(
          'Szczegóły ogłoszenia',
          style: TextStyle(
              color: colorSepia, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton.filled(
              onPressed: () {},
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
              Hero(
                tag: announcement.imageURL,
                child: Container(
                  decoration: backgroundBoxDecoration,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - 40,
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
                        style: const TextStyle(
                          color: colorSepia,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      announcement.latinName.isNotEmpty
                          ? Text(
                              announcement.latinName,
                              style: const TextStyle(
                                color: colorSepia,
                                fontWeight: FontWeight.w200,
                                fontSize: 19,
                              ),
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
                        : 'Brak dodatkowego opisu.',
                    style: const TextStyle(
                      color: colorSepia,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
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
                      const Text(
                        'Liczba sadzonek: ',
                        style: TextStyle(
                            color: colorSepia,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                      Text(
                        '${announcement.seedCount}',
                        style: const TextStyle(color: colorSepia, fontSize: 17),
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
                      const Text(
                        'Odbiór: ',
                        style: TextStyle(
                            color: colorSepia,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                      Text(
                        announcement.city,
                        style: const TextStyle(color: colorSepia, fontSize: 17),
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
                      const Text(
                        'Dodano przez: ',
                        style: TextStyle(
                            color: colorSepia,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                      Row(
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
                                color: colorSepia, fontSize: 17),
                          ),
                        ],
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
                  onPressed: () {},
                  child: const Text('Wyślij wiadomość'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}