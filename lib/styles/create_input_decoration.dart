import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/styles/text_styles.dart';

InputDecoration createInputDecoration({required String label}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyles.bodyTextStyle(opacity: 0.5),
    floatingLabelStyle: TextStyles.calloutTextStyle(
      color: colorDarkMossGreen,
      weight: FontWeight.bold,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: colorDarkMossGreen,
      ),
      borderRadius: BorderRadius.circular(12.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: colorSepia,
      ),
      borderRadius: BorderRadius.circular(12.0),
    ),
  );
}
