import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/styles/text_styles.dart';

RichText getStatusTextFrom(int status) {
  String statusText = '';
  Color textColor = colorSepia;

  switch (status) {
    case 0:
      statusText = 'W poczekalni';
    case 1:
      statusText = 'Zaakceptowano';
      textColor = colorDarkMossGreen;
    case 2:
      statusText = 'Odrzucono';
      textColor = colorRedKenyanCopper;
    case 3:
      statusText = 'Zarchiwizowano';
    default:
      statusText = 'Nieznany';
  }

  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: 'Status ogłoszenia:  ',
          style: TextStyles.calloutTextStyle(),
        ),
        TextSpan(
          text: statusText,
          style: TextStyles.bodyTextStyle(
            weight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}
