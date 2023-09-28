import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart' show immutable;

@immutable
abstract class AddScreenEvent {
  const AddScreenEvent();
}

@immutable
class AddNewAnnouncementAddScreenEvent implements AddScreenEvent {
  final User user;
  final String name;
  final String latinName;
  final String imagePath;
  final int seedCount;
  final String city;
  final String description;

  const AddNewAnnouncementAddScreenEvent({
    required this.user,
    required this.name,
    required this.latinName,
    required this.imagePath,
    required this.seedCount,
    required this.city,
    required this.description,
  });
}

@immutable
class FieldsWasClearedAddScreenEvent implements AddScreenEvent {
  const FieldsWasClearedAddScreenEvent();
}
