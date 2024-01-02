import 'package:flutter/material.dart';

import '../color.dart';

class Loader extends StatelessWidget {
  const Loader({super.key, this.color, this.size});
  final Color? color;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size ?? 15,
      width: size ?? 15,
      child: Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(color ?? Colors.white),
        backgroundColor: color != null
            ? color?.withOpacity(0.1)
            : Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : black(context).withOpacity(0.1),
        strokeWidth: 0.5,
      )),
    );
  }
}
