import 'package:flutter/material.dart';
import 'package:planted/styles/text_styles.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyles.bodyTextStyle(opacity: 0.5),
        ),
      ),
    );
  }
}
