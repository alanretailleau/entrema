import 'package:flutter/material.dart';

class Money extends StatelessWidget {
  final double price;
  final TextStyle? style;

  Money({required this.price, this.style});

  @override
  Widget build(BuildContext context) {
    // Séparer les euros et les centimes
    List<String> parts = price.toStringAsFixed(2).split('.');

    return RichText(
      text: TextSpan(
        style: style ?? DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: parts[0], // Euros
            style:
                TextStyle(fontSize: style != null ? style!.fontSize ?? 24 : 24),
          ),
          TextSpan(
            text: '.${parts[1]}', // Centimes
            style: TextStyle(
                fontSize: style != null
                    ? style!.fontSize != null
                        ? style!.fontSize! / 1.5
                        : 16
                    : 16,
                fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: ' €', // Symbole de l'euro
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: style != null
                  ? style!.fontSize != null
                      ? style!.fontSize! / 1.5
                      : 16
                  : 16,
            ),
          ),
        ],
      ),
    );
  }
}
