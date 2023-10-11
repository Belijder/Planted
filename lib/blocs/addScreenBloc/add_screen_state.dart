import 'package:flutter/material.dart' show immutable;
import 'package:planted/blocs/database_error.dart';
import 'package:equatable/equatable.dart';

@immutable
class AddScreenState extends Equatable {
  final bool isLoading;
  final DatabaseError? databaseError;
  final bool shouldCleanFields;
  final String? snackbarMessage;

  const AddScreenState({
    required this.isLoading,
    this.databaseError,
    this.shouldCleanFields = false,
    this.snackbarMessage,
  });

  @override
  List<Object?> get props =>
      [isLoading, databaseError, shouldCleanFields, snackbarMessage];
}
