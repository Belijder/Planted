import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';

final filledButtonStyle = ElevatedButton.styleFrom(
  shadowColor: colorSepia,
  elevation: 3,
  backgroundColor: colorDarkMossGreen,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  textStyle: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  ),
);

final outlinedButtonStyle = OutlinedButton.styleFrom(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  side: const BorderSide(color: colorDarkMossGreen),
  textStyle: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  ),
  foregroundColor: colorDarkMossGreen,
);
