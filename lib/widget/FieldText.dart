import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:entrema/widget/button.dart';

import '../color.dart';

class FieldText extends StatelessWidget {
  const FieldText(
      {super.key,
      required this.controllerFR,
      this.controllerEN,
      this.eye,
      this.hintText,
      this.inputFormatters,
      required this.onChanged,
      this.hintColor,
      this.validator,
      this.fontWeight,
      this.textCapitalization,
      this.color,
      this.fr,
      this.borderColor,
      this.textColor,
      this.search,
      this.onFieldSubmitted,
      this.fontFamily,
      this.obscureText,
      this.keyboardType,
      this.focusNode,
      this.radius,
      this.fontSize,
      this.alignment,
      this.flag,
      this.eyeClick,
      this.maxLength,
      this.padding,
      this.autofocus,
      this.textInputAction,
      this.maxLines,
      this.autoCorrect});
  final TextEditingController controllerFR;
  final TextEditingController? controllerEN;
  final bool? fr;
  final Function()? flag;
  final Function()? eyeClick;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign? alignment;
  final TextInputAction? textInputAction;
  final double? fontSize;
  final double? radius;
  final FontWeight? fontWeight;
  final Color? color, borderColor, textColor;
  final String? hintText;
  final int? maxLines, maxLength;
  final TextCapitalization? textCapitalization;
  final TextInputType? keyboardType;
  final bool? autoCorrect, autofocus, search, eye;
  final Color? hintColor;
  final String? Function(String?)? validator, onChanged, onFieldSubmitted;
  final FocusNode? focusNode;
  final String? fontFamily;
  final EdgeInsetsGeometry? padding;
  final bool? obscureText;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          border:
              Border.all(color: borderColor ?? Colors.transparent, width: 3),
          borderRadius: BorderRadius.circular(radius ?? 10),
          color: color ?? Theme.of(context).primaryColor),
      child: Center(
        child: Row(
          children: [
            search == true
                ? SizedBox(
                    height: 15,
                    width: 15,
                    child: Image.asset("assets/icon/search.png",
                        scale: 10,
                        color: Theme.of(context)
                            .primaryColorDark
                            .withOpacity(0.5)))
                : Container(),
            controllerEN != null
                ? SizedBox(
                    height: 40,
                    width: 40,
                    child: CustomButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.zero,
                        onPressed: flag,
                        child: Text(fr! ? "🇫🇷" : "🇬🇧",
                            style: const TextStyle(fontSize: 20))),
                  )
                : Container(),
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
                controller: fr != false || controllerEN == null
                    ? controllerFR
                    : controllerEN,
                textCapitalization:
                    textCapitalization ?? TextCapitalization.sentences,
                cursorColor: blue,
                cursorRadius: const Radius.circular(10),
                style: TextStyle(
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
                    hintText: hintText),
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
    );
  }
}
