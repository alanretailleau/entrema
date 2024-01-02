import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:entrema/widget/button.dart';

import '../color.dart';

class FieldText2 extends StatelessWidget {
  const FieldText2(
      {super.key,
      required this.controller,
      this.eye,
      this.hintText,
      this.hintText2,
      this.inputFormatters,
      required this.onChanged,
      this.hintColor,
      this.validator,
      this.fontWeight,
      this.textCapitalization,
      this.color,
      this.borderColor,
      this.textColor,
      this.onFieldSubmitted,
      this.fontFamily,
      this.obscureText,
      this.keyboardType,
      this.focusNode,
      this.fontSize,
      this.alignment,
      this.flag,
      this.eyeClick,
      this.maxLength,
      this.padding,
      this.italic,
      this.autofocus,
      this.textInputAction,
      this.maxLines,
      this.autoCorrect});
  final TextEditingController controller;
  final Function()? flag;
  final Function()? eyeClick;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign? alignment;
  final TextInputAction? textInputAction;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color, borderColor, textColor;
  final String? hintText, hintText2;
  final int? maxLines, maxLength;
  final TextCapitalization? textCapitalization;
  final TextInputType? keyboardType;
  final bool? autoCorrect, autofocus, eye, italic;
  final Color? hintColor;
  final String? Function(String?)? validator, onChanged, onFieldSubmitted;
  final FocusNode? focusNode;
  final String? fontFamily;
  final EdgeInsetsGeometry? padding;
  final bool? obscureText;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        hintText != null
            ? Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Text(hintText!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w900)),
              )
            : Container(),
        Container(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(
              border: Border.all(
                  color: borderColor ?? Colors.transparent, width: 1),
              borderRadius: BorderRadius.circular(100),
              color: color ?? Theme.of(context).primaryColor),
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    inputFormatters: inputFormatters,
                    focusNode: focusNode,
                    autofocus: autofocus ?? false,
                    textInputAction: textInputAction,
                    onFieldSubmitted: onFieldSubmitted,
                    onChanged: onChanged,
                    maxLength: maxLength,
                    maxLines: maxLines ?? 1,
                    validator: validator,
                    controller: controller,
                    textCapitalization:
                        textCapitalization ?? TextCapitalization.sentences,
                    cursorColor: blue,
                    cursorRadius: const Radius.circular(10),
                    style: TextStyle(
                        fontStyle: italic == true
                            ? FontStyle.italic
                            : FontStyle.normal,
                        color: textColor,
                        fontFamily: fontFamily,
                        fontWeight: fontWeight,
                        fontSize: fontSize),
                    keyboardType: keyboardType ?? TextInputType.text,
                    autocorrect: autoCorrect ?? true,
                    textAlign: alignment ?? TextAlign.center,
                    obscureText: obscureText ?? false,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintStyle:
                            TextStyle(fontFamily: fontFamily, color: hintColor),
                        hintText: hintText2),
                  ),
                ),
                eye != null
                    ? SizedBox(
                        height: 40,
                        width: 40,
                        child: CustomButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.zero,
                            onPressed: eyeClick,
                            child: Image.asset(
                              eye == true
                                  ? "assets/icon/visible.png"
                                  : "assets/icon/invisible.png",
                              color: black(context),
                              scale: 10,
                            )),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
