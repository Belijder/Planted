import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';

class TextStyles {
  static TextStyle largeTitleTextStyle({
    FontWeight weight = FontWeight.normal,
    Color color = colorSepia,
  }) =>
      TextStyle(
        color: color,
        fontWeight: weight,
        fontSize: 30,
      );

  static TextStyle titleTextStyle({
    FontWeight weight = FontWeight.normal,
    Color color = colorSepia,
  }) =>
      TextStyle(
        color: color,
        fontWeight: weight,
        fontSize: 18,
      );

  static TextStyle headlineTextStyle({
    FontWeight weight = FontWeight.normal,
    Color color = colorSepia,
  }) =>
      TextStyle(
        color: color,
        fontWeight: weight,
        fontSize: 16,
      );

  static TextStyle bodyTextStyle({
    FontWeight weight = FontWeight.normal,
    Color color = colorSepia,
    double opacity = 1.0,
  }) =>
      TextStyle(
        color: color.withOpacity(opacity),
        fontWeight: weight,
        fontSize: 14,
      );

  static TextStyle calloutTextStyle(
          {FontWeight weight = FontWeight.normal,
          Color color = colorSepia,
          double opacity = 1.0,
          TextDecoration? decoration}) =>
      TextStyle(
        fontWeight: weight,
        color: color.withOpacity(opacity),
        fontSize: 12,
        decoration: decoration,
      );

  static TextStyle captionTextStyle({
    FontWeight weight = FontWeight.normal,
    Color color = colorSepia,
  }) =>
      TextStyle(
        color: color,
        fontWeight: weight,
        fontSize: 10,
      );
}
