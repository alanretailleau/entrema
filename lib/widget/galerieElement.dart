import 'dart:async';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/widget/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import '../classes/galerie.dart';
import '../classes/picture.dart';
import '../functions/function.dart';
import '../functions/functionWeb.dart';

class GalerieElementV2 extends StatelessWidget {
  GalerieElementV2(
      {super.key,
      this.url,
      required this.idUser,
      required this.context,
      this.quality = "high",
      this.cache = false,
      required this.info,
      this.width,
      this.full = false,
      this.height,
      required this.radius,
      this.onPressed,
      this.onLongPress,
      this.colorCover,
      this.nom,
      this.surnom,
      this.edit});
  final Picture info;
  String? url;
  final bool full;
  final String idUser;
  final bool cache;
  final String quality;
  final BuildContext context;
  final bool? edit;
  final Function()? onLongPress;
  final String? nom, surnom;
  final bool? colorCover;
  final Function()? onPressed;
  final double? height, width, radius;

  Widget cacheW(widget, url) {
    return SizedBox(
        height: !full ? height : null,
        width: !full ? width : null,
        child: CachedNetworkImage(
          useOldImageOnUrlChange: true,
          maxHeightDiskCache: height != null ? (height! * 1.5).round() : 500,
          maxWidthDiskCache: width != null ? (width! * 1.5).round() : 500,
          fit: BoxFit.cover,
          imageUrl: url,
          placeholder: (context, url) => Container(),
          //Center(child: Loader(color: black(context))),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ));
  }

  void addStats(String idPage, String idUser, String type, Map data) {
    FirebaseFirestore.instance.collection("statistique").add({
      "idUser": idUser,
      "idPage": idPage,
      "type": type,
      "date": DateTime.now(),
      "data": data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius ?? 10)),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(radius ?? 10),
                child: image(info.url, width, height))),
        Positioned.fill(
          top: 0,
          bottom: 0,
          child: SizedBox(
            height: height,
            width: width,
            child: CustomButton(
              onLongPress: onLongPress,
              color: Colors.white.withOpacity(0),
              onPressed: onPressed ??
                  () {
                    if (info.galerie != "") {
                      addStats(info.galerie, idUser, "view",
                          {"from": "image", "click": "press"});
                    }
                    showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                            backgroundColor: info.darkColor.withOpacity(.1),
                            insetPadding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: AspectRatio(
                                aspectRatio:
                                    (info.width / info.height).toDouble(),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                        clipBehavior: Clip.none,
                                        borderRadius: BorderRadius.circular(10),
                                        child: PhotoView(
                                            gaplessPlayback: true,
                                            maxScale: PhotoViewComputedScale
                                                    .contained *
                                                3,
                                            minScale: PhotoViewComputedScale
                                                .contained,
                                            initialScale: PhotoViewComputedScale
                                                .contained,
                                            imageProvider:
                                                NetworkImage(info.url))),
                                    Positioned(
                                        top: 20,
                                        left: 20,
                                        child: SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: CustomButton(
                                              padding: EdgeInsets.zero,
                                              shape: const StadiumBorder(),
                                              color:
                                                  Colors.black.withOpacity(.1),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Image.asset(
                                                  "assets/icon/cancel.png",
                                                  color: Colors.white,
                                                  scale: 10)),
                                        )),
                                  ],
                                )));
                      },
                    );
                  },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius ?? 10)),
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }

  Widget image(url, width, height) {
    if (url != "" && url != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          cacheW(
              SizedBox(
                height: !full ? height : null,
                width: !full ? width : null,
                child: Image(
                  image: width != null || height != null
                      ? ResizeImage(NetworkImage(url),
                          policy: ResizeImagePolicy.fit,
                          width: width != null ? (width! * 2.5).round() : null,
                          height:
                              height != null ? (height! * 2.5).round() : null)
                      : NetworkImage(url) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              url),
          colorCover == true
              ? Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [0.1, 1],
                          colors: edit != true
                              ? [
                                  darken(info.darkColor.withOpacity(0.6), 0.2),
                                  Colors.transparent
                                ]
                              : [
                                  Colors.black.withOpacity(.6),
                                  Colors.black.withOpacity(.6)
                                ]),
                      borderRadius: BorderRadius.circular(radius ?? 20),
                    ),
                  ))
              : Container(),
          nom != null && edit != true
              ? Positioned(
                  bottom: 10,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(nom ?? "",
                        style: TextStyle(
                            fontFamily: "Circular",
                            color: Colors.white.withOpacity(.6))),
                  ))
              : Container(),
          surnom != null && edit != true
              ? Positioned(
                  bottom: nom == null || nom == "" ? 10 : 22,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(surnom ?? "",
                        style: TextStyle(
                            height: 0.8,
                            fontFamily: "Circular",
                            fontWeight: FontWeight.bold,
                            fontSize: width! > 120 ? 25 : 18,
                            color: Colors.white)),
                  ))
              : Container(),
          edit == true
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: Image.asset(
                    "assets/icon/add.png",
                    color: Colors.white,
                    scale: 10,
                  ),
                )
              : Container()
        ],
      );
    } else {
      return Image.asset("assets/icon/transparent_image.png");
    }
  }
}

class ImageDetail {
  final int width;
  final int height;
  final Uint8List? bytes;

  ImageDetail({required this.width, required this.height, this.bytes});
}
