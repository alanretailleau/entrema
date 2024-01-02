import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/classes/picture.dart';
import 'package:flutter/material.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/user.dart';
import 'package:entrema/widget/galerieElement.dart';
import '../functions/function.dart';
import 'button.dart';

class Account extends StatelessWidget {
  const Account({super.key, required this.user, required this.commerce});
  final User user;
  final Commerce commerce;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [user.couleur, user.couleur.withOpacity(.6)])),
      child: CustomButton(
        color: Colors.white.withOpacity(0),
        padding: const EdgeInsets.all(5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: () async {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: user.url.toString(),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white, width: 3)),
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: GalerieElementV2(
                            idUser: user.id,
                            height: 50,
                            width: 50,
                            radius: 25,
                            context: context,
                            info: Picture(
                                darkColor: Colors.white,
                                lightColor: Colors.white,
                                width: 50,
                                height: 50,
                                url: user.url != null
                                    ? user.url.toString()
                                    : "https://firebasestorage.googleapis.com/v0/b/anciens-de-bf.appspot.com/o/background.jpg?alt=media&token=df82faff-8eaa-4265-bbdc-e10faf772523",
                                galerie: ""))),
                    CustomButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        child: const SizedBox(
                          height: 40,
                          width: 40,
                        ),
                        onPressed: () {
                          //publishImage(context, user.couleur, user.id);
                        })
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                height: 80,
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width >
                            MediaQuery.of(context).size.height
                        ? MediaQuery.of(context).size.width / 4 - 100
                        : MediaQuery.of(context).size.width - 100),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -5,
                      child: Text("${user.prenom} ${user.nom}",
                          style: const TextStyle(
                              fontFamily: "Nexa",
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: Container()),
            Container()
          ],
        ),
      ),
    );
  }
}
