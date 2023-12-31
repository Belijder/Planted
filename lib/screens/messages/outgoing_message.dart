import 'package:flutter/material.dart';
import 'package:planted/styles/box_decoration_styles.dart';
import 'package:planted/styles/text_styles.dart';

class OutgoingMessage extends StatelessWidget {
  const OutgoingMessage({
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
              const Expanded(
                  child: SizedBox(
                height: 10,
              )),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: greenBackgroundBoxDecoration,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    message,
                    style: TextStyles.bodyTextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }
}
