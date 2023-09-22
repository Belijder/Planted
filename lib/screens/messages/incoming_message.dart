import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/styles/box_decoration_styles.dart';

class IncomingMessage extends StatelessWidget {
  const IncomingMessage({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: backgroundBoxDecoration,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    message,
                    style: const TextStyle(color: colorSepia),
                  ),
                ),
              ),
              const Expanded(
                  child: SizedBox(
                height: 10,
              ))
            ],
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }
}
