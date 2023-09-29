import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';

final backgroundBoxDecoration = BoxDecoration(
  color: listTileBackground,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: colorSepia.withAlpha(50),
      blurRadius: 4,
      offset: const Offset(0, 4),
    ),
  ],
);

final greenBackgroundBoxDecoration = BoxDecoration(
  color: colorDarkMossGreen,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: colorSepia.withAlpha(50),
      blurRadius: 4,
      offset: const Offset(0, 4),
    ),
  ],
);

final cupertinoModalPopapBoxDecoration = BoxDecoration(
  color: listTileBackground,
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  ),
  boxShadow: [
    BoxShadow(
      color: colorSepia.withAlpha(50),
      blurRadius: 4,
      offset: const Offset(0, 4),
    ),
  ],
);
