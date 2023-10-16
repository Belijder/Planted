import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/styles/text_styles.dart';

final filledButtonStyle = ElevatedButton.styleFrom(
  shadowColor: colorSepia,
  elevation: 3,
  backgroundColor: colorDarkMossGreen,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  textStyle: TextStyles.bodyTextStyle(weight: FontWeight.bold),
);

ButtonStyle createFilledButtonStyle({
  Color backgroundColor = colorDarkMossGreen,
  Color foregroundColor = Colors.white,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
}) =>
    ElevatedButton.styleFrom(
      shadowColor: colorSepia,
      elevation: 3,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      textStyle: TextStyles.bodyTextStyle(weight: FontWeight.bold),
    );

ButtonStyle createOutlinedButtonStyle({
  Color borderColor = colorDarkMossGreen,
  Color foregroundColor = colorDarkMossGreen,
}) =>
    OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: BorderSide(color: borderColor),
      textStyle: TextStyles.bodyTextStyle(weight: FontWeight.bold),
      foregroundColor: foregroundColor,
    );

final outlinedButtonStyle = OutlinedButton.styleFrom(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  side: const BorderSide(color: colorDarkMossGreen),
  textStyle: TextStyles.bodyTextStyle(weight: FontWeight.bold),
  foregroundColor: colorDarkMossGreen,
);
