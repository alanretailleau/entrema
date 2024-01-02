import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.onPressed,
      required this.child,
      this.onLongPress,
      this.shape,
      this.disabledTextColor,
      this.padding,
      this.highlightColor,
      this.disabledColor,
      this.color,
      this.minWidth,
      this.minHeight,
      this.materialTapTargetSize,
      this.splashColor});
  final Widget child;
  final Color? highlightColor,
      splashColor,
      color,
      disabledColor,
      disabledTextColor;
  final MaterialTapTargetSize? materialTapTargetSize;
  final Function()? onPressed, onLongPress;
  final double? minWidth, minHeight;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return RawMaterialButton(
      materialTapTargetSize: materialTapTargetSize,
      constraints:
          BoxConstraints(minWidth: minWidth ?? 50, minHeight: minHeight ?? 35),
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      key: key,
      padding: padding ?? const EdgeInsets.all(5),
      highlightColor:
          // ignore: prefer_null_aware_operators
          highlightColor ?? (color != null ? color?.withOpacity(.1) : null),
      fillColor: onPressed != null ? color : disabledColor,
      splashColor:
          // ignore: prefer_null_aware_operators
          splashColor ?? (color != null ? color?.withOpacity(.1) : null),
      onPressed: onPressed,
      onLongPress: onLongPress,
      shape: shape ?? const RoundedRectangleBorder(),
      child: child,
    );
  }
}
