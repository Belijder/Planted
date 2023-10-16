import 'package:flutter/material.dart';

AnimatedSwitcher createAnimatedSwitcher({required Widget child}) {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 200),
    switchInCurve: Curves.easeInOut,
    switchOutCurve: Curves.fastOutSlowIn,
    transitionBuilder: (child, animation) {
      final scaleAnimation = Tween<double>(
        begin: 0.85,
        end: 1.0,
      ).animate(animation);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: child,
        ),
      );
    },
    layoutBuilder: (currentChild, previousChildren) {
      return currentChild ?? Container();
    },
    child: child,
  );
}
