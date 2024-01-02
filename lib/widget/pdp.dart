import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../classes/user.dart';

class Pdp extends StatelessWidget {
  const Pdp(
      {super.key,
      required this.user,
      required this.height,
      required this.radius});
  final User user;
  final double height, radius;
  @override
  Widget build(BuildContext context) {
    if (user.url != null) {
      return SizedBox(
        height: height,
        width: height,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: CachedNetworkImage(
              useOldImageOnUrlChange: true,
              maxHeightDiskCache: height.round() * 2,
              maxWidthDiskCache: height.round() * 2,
              fit: BoxFit.cover,
              imageUrl: user.url!,
              placeholder: (context, url) => Container(),
              //Center(child: Loader(color: black(context))),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )),
      );
    } else {
      return Container(
          height: height,
          width: height,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: Theme.of(context).primaryColor),
          child: Center(
            child: Text("👻",
                style: TextStyle(
                    fontSize: height < 130 ? height / 2 : height / 4,
                    color: Colors.white)),
          ));
    }
  }
}
