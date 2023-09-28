import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorSepia.withAlpha(150),
          fontSize: 15,
        ),
      ),
    );
  }
}
