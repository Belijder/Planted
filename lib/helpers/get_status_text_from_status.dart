import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';

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
        const TextSpan(
          text: 'Status ogłoszenia:  ',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.normal,
            color: colorSepia,
          ),
        ),
        TextSpan(
          text: statusText,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}
