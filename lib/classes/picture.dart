import 'package:flutter/material.dart';

class Picture {
  Color darkColor;
  Color lightColor;
  String url;
  String galerie;
  double width;
  double height;

  Picture(
      {required this.darkColor,
      required this.lightColor,
      required this.width,
      required this.height,
      required this.url,
      required this.galerie});

  factory Picture.empty() {
    return Picture(
        darkColor: Colors.black,
        lightColor: Colors.white,
        width: 100,
        height: 100,
        url:
            "https://firebasestorage.googleapis.com/v0/b/ema-f19fe.appspot.com/o/transparent_image.png?alt=media&token=a410f562-c31f-45cf-af8c-b80a79746818",
        galerie: "");
  }

  factory Picture.fromInfo(Map info) {
    return Picture(
        width: info["width"] ?? 100,
        height: info["height"] ?? 100,
        darkColor: info["colors"] != null
            ? Color(int.parse("0xff${info["colors"][1]}"))
            : Colors.white,
        lightColor: info["colors"] != null
            ? Color(int.parse("0xff${info["colors"][0]}"))
            : Colors.black,
        url: info["url"] != null && info["url"] != ""
            ? info["url"]
            : "https://firebasestorage.googleapis.com/v0/b/ema-f19fe.appspot.com/o/transparent_image.png?alt=media&token=a410f562-c31f-45cf-af8c-b80a79746818",
        galerie: info["galerie"] ?? "");
  }

  Map toInfo() {
    return {
      "url": url,
      "width": width,
      "height": height,
      "colors": [
        lightColor.value.toRadixString(16),
        darkColor.value.toRadixString(16)
      ],
      "galerie": galerie
    };
  }
}
