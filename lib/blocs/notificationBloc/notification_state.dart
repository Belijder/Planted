import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
class NotificationState extends Equatable {
  final int currentBadgeNumber;
  final Iterable<String> conversationsIDs;

  const NotificationState({
    required this.currentBadgeNumber,
    required this.conversationsIDs,
  });

  @override
  List<Object?> get props => [
        currentBadgeNumber,
        conversationsIDs,
      ];
}
