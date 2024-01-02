import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/role.dart';
import 'package:entrema/classes/team.dart';
import 'package:entrema/classes/user.dart';
import 'package:entrema/color.dart';
import 'package:entrema/home/home.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../maths/romanScript.dart';
import '../widget/button.dart';

Future pushPage(BuildContext context, Widget page) {
  /*Navigator.of(context).push(
    FadeRoute(page: page),
  );*/
  return Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

List<Autorisation> getAuth(Commerce commerce, String userId) {
  // Trouver le membre de l'équipe correspondant à l'utilisateur
  Team teamMember = commerce.team.firstWhere(
    (member) => member.userId == userId,
    orElse: () => Team(userId: "", roleId: ""),
  );

  if (teamMember.userId == "") {
    // L'utilisateur n'est pas trouvé dans l'équipe, retourner une liste vide ou gérer l'erreur
    return [];
  }

  // Trouver le rôle associé à l'utilisateur
  Role userRole = commerce.roles.firstWhere(
    (role) => role.id == teamMember.roleId,
    orElse: () => Role(id: "", autorisations: [], nom: ""),
  );

  if (userRole.id == "") {
    // Le rôle n'est pas trouvé, retourner une liste vide ou gérer l'erreur
    return [];
  }

  // Retourner les autorisations du rôle
  return userRole.autorisations;
}

Future<List<DocumentSnapshot>> getBadges(
    String infoId, List badge, String myId, int limit) async {
  List<DocumentSnapshot> badges = [];
  for (var i = 0;
      i < (limit != -1 && limit < badge.length ? limit : badge.length);
      i++) {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("badge")
        .doc(badge[i])
        .get();
    if (doc.get("ecole") == infoId && doc.get("valide") == true) {
      badges.add(doc);
    }
    if (badges.last["restricted"].isNotEmpty &&
        !badges.last["restricted"].contains(myId)) {
      badges.removeLast();
    }
  }
  return badges;
}

List<String> searchTerm(List<String> element) {
  List<String> searchTerm = [];
  for (var i = 0; i < element.length; i++) {
    for (var j = 0; j < element[i].length; j++) {
      searchTerm
          .add(removeDiacritics(element[i].substring(0, j + 1)).toLowerCase());
    }
  }
  var seen = <String>{};
  List<String> uniquelist = searchTerm.where((term) => seen.add(term)).toList();
  return uniquelist;
}

Future<Color> chooseColor(BuildContext context) async {
  List<Color> colors = [
    Color(0xfff72585),
    Color(0xffb5179e),
    Color(0xff7209b7),
    Color(0xff480ca8),
    Color(0xff3a0ca3),
    Color(0xff3f37c9),
    Color(0xff4361ee),
    Color(0xff4895ef),
    Color(0xffff7b00),
    Color(0xffff9500),
    Color(0xffffaa00),
    Color(0xffffc300),
    Color(0xff8c07dd),
    Color(0xffcb5df1),
    Color(0xffff95b5),
    Color(0xffb9375e),
    Color(0xff004b23),
    Color(0xff007200),
    Color(0xff38b000),
    Color(0xff70e000),
    Color(0xff9ef01a),
    Color(0xff4ad66d),
    Color(0xff25a244),
    Color(0xff90e0ef),
    Color(0xff00b4d8),
    Color(0xff0096c7),
    Color(0xff0077b6),
    Color(0xff023e8a),
    Color(0xff03045e)
  ];
  return await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Container(
              height: 90,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  color: white(context)),
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CustomButton(
                            color: colors[index],
                            shape: StadiumBorder(
                                side: BorderSide(
                                    color: black(context).withOpacity(.1))),
                            onPressed: () {
                              Navigator.pop(context, colors[index]);
                            },
                            child: Container()),
                      ),
                    );
                  })),
        );
      });
}

Future<bool> editDialog(
    BuildContext context, String no, String yes, String text) async {
  return await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                color: white(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            color: Colors.red.withOpacity(.1),
                            child: Text(no,
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.pop(context, false);
                            }),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: CustomButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            color: blue.withOpacity(.1),
                            child: Text(yes,
                                style: TextStyle(
                                    color: blue, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.pop(context, true);
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
}

Future<dynamic> getEmoji(context, {bool change = false}) {
  List<Map> emoji = [
    {
      "name": "Les plus utilisés",
      "emoji": [
        {
          "value": "❤️",
          "searchTerm": [],
        },
        {
          "value": "🫶",
          "searchTerm": [],
        },
        {
          "value": "💀",
          "searchTerm": [],
        },
        {
          "value": "🫠",
          "searchTerm": [],
        },
        {
          "value": "🔥",
          "searchTerm": [],
        },
        {
          "value": "👍",
          "searchTerm": [],
        },
        {
          "value": "👎",
          "searchTerm": [],
        },
        {
          "value": "🤣",
          "searchTerm": [],
        },
        {
          "value": "😆",
          "searchTerm": [],
        },
        {
          "value": "😊",
          "searchTerm": [],
        },
        {
          "value": "😉",
          "searchTerm": [],
        },
        {
          "value": "🥰",
          "searchTerm": [],
        },
        {
          "value": "😍",
          "searchTerm": [],
        },
        {
          "value": "😎",
          "searchTerm": [],
        },
        {
          "value": "🤩",
          "searchTerm": [],
        },
        {
          "value": "😜",
          "searchTerm": [],
        },
        {
          "value": "🥳",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Souriant et affectueux",
      "emoji": [
        {
          "value": "😀",
          "searchTerm": [],
        },
        {
          "value": "😃",
          "searchTerm": [],
        },
        {
          "value": "😄",
          "searchTerm": [],
        },
        {
          "value": "😁",
          "searchTerm": [],
        },
        {
          "value": "😆",
          "searchTerm": [],
        },
        {
          "value": "😅",
          "searchTerm": [],
        },
        {
          "value": "🤣",
          "searchTerm": [],
        },
        {
          "value": "😂",
          "searchTerm": [],
        },
        {
          "value": "🙂",
          "searchTerm": [],
        },
        {
          "value": "😉",
          "searchTerm": [],
        },
        {
          "value": "😉",
          "searchTerm": [],
        },
        {
          "value": "😊",
          "searchTerm": [],
        },
        {
          "value": "😇",
          "searchTerm": [],
        },
        {
          "value": "🥰",
          "searchTerm": [],
        },
        {
          "value": "😍",
          "searchTerm": [],
        },
        {
          "value": "😘",
          "searchTerm": [],
        },
        {
          "value": "😗",
          "searchTerm": [],
        },
        {
          "value": "☺️",
          "searchTerm": [],
        },
        {
          "value": "😚",
          "searchTerm": [],
        },
        {
          "value": "😙",
          "searchTerm": [],
        },
        {
          "value": "🥲",
          "searchTerm": [],
        },
        {
          "value": "😏",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Langues, mains et accessoires",
      "emoji": [
        {
          "value": "😋",
          "searchTerm": [],
        },
        {
          "value": "😛",
          "searchTerm": [],
        },
        {
          "value": "😜",
          "searchTerm": [],
        },
        {
          "value": "🤪",
          "searchTerm": [],
        },
        {
          "value": "😝",
          "searchTerm": [],
        },
        {
          "value": "🤗",
          "searchTerm": [],
        },
        {
          "value": "🤭",
          "searchTerm": [],
        },
        {
          "value": "🫢",
          "searchTerm": [],
        },
        {
          "value": "🫣",
          "searchTerm": [],
        },
        {
          "value": "🤫",
          "searchTerm": [],
        },
        {
          "value": "🤔",
          "searchTerm": [],
        },
        {
          "value": "🫡",
          "searchTerm": [],
        },
        {
          "value": "🤤",
          "searchTerm": [],
        },
        {
          "value": "🤠",
          "searchTerm": [],
        },
        {
          "value": "🥳",
          "searchTerm": [],
        },
        {
          "value": "🥸",
          "searchTerm": [],
        },
        {
          "value": "😎",
          "searchTerm": [],
        },
        {
          "value": "🤓",
          "searchTerm": [],
        },
        {
          "value": "🧐",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Neutre et sceptique",
      "emoji": [
        {
          "value": "🙃",
          "searchTerm": [],
        },
        {
          "value": "🫠",
          "searchTerm": [],
        },
        {
          "value": "🤐",
          "searchTerm": [],
        },
        {
          "value": "🤨",
          "searchTerm": [],
        },
        {
          "value": "😐",
          "searchTerm": [],
        },
        {
          "value": "😑",
          "searchTerm": [],
        },
        {
          "value": "😶",
          "searchTerm": [],
        },
        {
          "value": "🫥",
          "searchTerm": [],
        },
        {
          "value": "😶‍🌫️",
          "searchTerm": [],
        },
        {
          "value": "😒",
          "searchTerm": [],
        },
        {
          "value": "🙄",
          "searchTerm": [],
        },
        {
          "value": "😬",
          "searchTerm": [],
        },
        {
          "value": "🫨",
          "searchTerm": [],
        },
        {
          "value": "😮‍💨",
          "searchTerm": [],
        },
        {
          "value": "🤥",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Somnolent et malade",
      "emoji": [
        {
          "value": "😌",
          "searchTerm": [],
        },
        {
          "value": "😔",
          "searchTerm": [],
        },
        {
          "value": "😪",
          "searchTerm": [],
        },
        {
          "value": "😴",
          "searchTerm": [],
        },
        {
          "value": "😷",
          "searchTerm": [],
        },
        {
          "value": "🤒",
          "searchTerm": [],
        },
        {
          "value": "🤕",
          "searchTerm": [],
        },
        {
          "value": "🤢",
          "searchTerm": [],
        },
        {
          "value": "🤮",
          "searchTerm": [],
        },
        {
          "value": "🤧",
          "searchTerm": [],
        },
        {
          "value": "🥵",
          "searchTerm": [],
        },
        {
          "value": "🥶",
          "searchTerm": [],
        },
        {
          "value": "🥴",
          "searchTerm": [],
        },
        {
          "value": "😵",
          "searchTerm": [],
        },
        {
          "value": "😵‍💫",
          "searchTerm": [],
        },
        {
          "value": "🤯",
          "searchTerm": [],
        },
        {
          "value": "🥱",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Préoccupé et négatif",
      "emoji": [
        {
          "value": "😕",
          "searchTerm": [],
        },
        {
          "value": "🫤",
          "searchTerm": [],
        },
        {
          "value": "😟",
          "searchTerm": [],
        },
        {
          "value": "🙁",
          "searchTerm": [],
        },
        {
          "value": "☹️",
          "searchTerm": [],
        },
        {
          "value": "😮",
          "searchTerm": [],
        },
        {
          "value": "😯",
          "searchTerm": [],
        },
        {
          "value": "😲",
          "searchTerm": [],
        },
        {
          "value": "😳",
          "searchTerm": [],
        },
        {
          "value": "🥺",
          "searchTerm": [],
        },
        {
          "value": "🥹",
          "searchTerm": [],
        },
        {
          "value": "😦",
          "searchTerm": [],
        },
        {
          "value": "😧",
          "searchTerm": [],
        },
        {
          "value": "😨",
          "searchTerm": [],
        },
        {
          "value": "😰",
          "searchTerm": [],
        },
        {
          "value": "😥",
          "searchTerm": [],
        },
        {
          "value": "😢",
          "searchTerm": [],
        },
        {
          "value": "😭",
          "searchTerm": [],
        },
        {
          "value": "😱",
          "searchTerm": [],
        },
        {
          "value": "😖",
          "searchTerm": [],
        },
        {
          "value": "😣",
          "searchTerm": [],
        },
        {
          "value": "😞",
          "searchTerm": [],
        },
        {
          "value": "😓",
          "searchTerm": [],
        },
        {
          "value": "😩",
          "searchTerm": [],
        },
        {
          "value": "😫",
          "searchTerm": [],
        },
        {
          "value": "😤",
          "searchTerm": [],
        },
        {
          "value": "😡",
          "searchTerm": [],
        },
        {
          "value": "😠",
          "searchTerm": [],
        },
        {
          "value": "🤬",
          "searchTerm": [],
        },
        {
          "value": "👿",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Costume, créature et animal",
      "emoji": [
        {
          "value": "😈",
          "searchTerm": [],
        },
        {
          "value": "👿",
          "searchTerm": [],
        },
        {
          "value": "💀",
          "searchTerm": [],
        },
        {
          "value": "☠️",
          "searchTerm": [],
        },
        {
          "value": "💩",
          "searchTerm": [],
        },
        {
          "value": "🤡",
          "searchTerm": [],
        },
        {
          "value": "👹",
          "searchTerm": [],
        },
        {
          "value": "👺",
          "searchTerm": [],
        },
        {
          "value": "👻",
          "searchTerm": [],
        },
        {
          "value": "👽",
          "searchTerm": [],
        },
        {
          "value": "👾",
          "searchTerm": [],
        },
        {
          "value": "🤖",
          "searchTerm": [],
        },
        {
          "value": "😺",
          "searchTerm": [],
        },
        {
          "value": "😸",
          "searchTerm": [],
        },
        {
          "value": "😹",
          "searchTerm": [],
        },
        {
          "value": "😻",
          "searchTerm": [],
        },
        {
          "value": "😼",
          "searchTerm": [],
        },
        {
          "value": "😽",
          "searchTerm": [],
        },
        {
          "value": "🙀",
          "searchTerm": [],
        },
        {
          "value": "😿",
          "searchTerm": [],
        },
        {
          "value": "😸",
          "searchTerm": [],
        },
        {
          "value": "😾",
          "searchTerm": [],
        },
        {
          "value": "🙈",
          "searchTerm": [],
        },
        {
          "value": "🙉",
          "searchTerm": [],
        },
        {
          "value": "🙊",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Mains et parties du corps",
      "emoji": [
        {
          "value": "👋",
          "searchTerm": [],
        },
        {
          "value": "🤚",
          "searchTerm": [],
        },
        {
          "value": "🖐️",
          "searchTerm": [],
        },
        {
          "value": "✋",
          "searchTerm": [],
        },
        {
          "value": "🖖",
          "searchTerm": [],
        },
        {
          "value": "🫱",
          "searchTerm": [],
        },
        {
          "value": "🫲",
          "searchTerm": [],
        },
        {
          "value": "🫳",
          "searchTerm": [],
        },
        {
          "value": "🫴",
          "searchTerm": [],
        },
        {
          "value": "👌",
          "searchTerm": [],
        },
        {
          "value": "🤌",
          "searchTerm": [],
        },
        {
          "value": "🤏",
          "searchTerm": [],
        },
        {
          "value": "✌️",
          "searchTerm": [],
        },
        {
          "value": "🤞",
          "searchTerm": [],
        },
        {
          "value": "🫰",
          "searchTerm": [],
        },
        {
          "value": "🤟",
          "searchTerm": [],
        },
        {
          "value": "🤘",
          "searchTerm": [],
        },
        {
          "value": "🤙",
          "searchTerm": [],
        },
        {
          "value": "👈",
          "searchTerm": [],
        },
        {
          "value": "👉",
          "searchTerm": [],
        },
        {
          "value": "👆",
          "searchTerm": [],
        },
        {
          "value": "🖕",
          "searchTerm": [],
        },
        {
          "value": "👇",
          "searchTerm": [],
        },
        {
          "value": "☝️",
          "searchTerm": [],
        },
        {
          "value": "🫵",
          "searchTerm": [],
        },
        {
          "value": "👍",
          "searchTerm": [],
        },
        {
          "value": "👎",
          "searchTerm": [],
        },
        {
          "value": "✊",
          "searchTerm": [],
        },
        {
          "value": "👊",
          "searchTerm": [],
        },
        {
          "value": "🤛",
          "searchTerm": [],
        },
        {
          "value": "🤜",
          "searchTerm": [],
        },
        {
          "value": "👏",
          "searchTerm": [],
        },
        {
          "value": "🙌",
          "searchTerm": [],
        },
        {
          "value": "🫶",
          "searchTerm": [],
        },
        {
          "value": "👐",
          "searchTerm": [],
        },
        {
          "value": "🤲",
          "searchTerm": [],
        },
        {
          "value": "🤝",
          "searchTerm": [],
        },
        {
          "value": "🙏",
          "searchTerm": [],
        },
        {
          "value": "✍️",
          "searchTerm": [],
        },
        {
          "value": "💅",
          "searchTerm": [],
        },
        {
          "value": "🤳",
          "searchTerm": [],
        },
        {
          "value": "💪",
          "searchTerm": [],
        },
        {
          "value": "🦾",
          "searchTerm": [],
        },
        {
          "value": "🦿",
          "searchTerm": [],
        },
        {
          "value": "🦵",
          "searchTerm": [],
        },
        {
          "value": "🦶",
          "searchTerm": [],
        },
        {
          "value": "👂",
          "searchTerm": [],
        },
        {
          "value": "🦻",
          "searchTerm": [],
        },
        {
          "value": "👃",
          "searchTerm": [],
        },
        {
          "value": "🧠",
          "searchTerm": [],
        },
        {
          "value": "🫀",
          "searchTerm": [],
        },
        {
          "value": "🫁",
          "searchTerm": [],
        },
        {
          "value": "🦷",
          "searchTerm": [],
        },
        {
          "value": "🦴",
          "searchTerm": [],
        },
        {
          "value": "👀",
          "searchTerm": [],
        },
        {
          "value": "👅",
          "searchTerm": [],
        },
        {
          "value": "👄",
          "searchTerm": [],
        },
        {
          "value": "🫦",
          "searchTerm": [],
        },
        {
          "value": "👣",
          "searchTerm": [],
        },
        {
          "value": "🧬",
          "searchTerm": [],
        },
        {
          "value": "🩸",
          "searchTerm": [],
        },
        {
          "value": "🫸",
          "searchTerm": [],
        },
        {
          "value": "🫷",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Personnes et apparence",
      "emoji": [
        {
          "value": "👶",
          "searchTerm": [],
        },
        {
          "value": "🧒",
          "searchTerm": [],
        },
        {
          "value": "👦",
          "searchTerm": [],
        },
        {
          "value": "👧",
          "searchTerm": [],
        },
        {
          "value": "🧑",
          "searchTerm": [],
        },
        {
          "value": "👱",
          "searchTerm": [],
        },
        {
          "value": "👨",
          "searchTerm": [],
        },
        {
          "value": "🧔",
          "searchTerm": [],
        },
        {
          "value": "🧔‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧔‍♀️",
          "searchTerm": [],
        },
        {
          "value": "👨‍🦰",
          "searchTerm": [],
        },
        {
          "value": "👨‍🦱",
          "searchTerm": [],
        },
        {
          "value": "👨‍🦳",
          "searchTerm": [],
        },
        {
          "value": "👨‍🦲",
          "searchTerm": [],
        },
        {
          "value": "👩",
          "searchTerm": [],
        },
        {
          "value": "👩‍🦰",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🦰",
          "searchTerm": [],
        },
        {
          "value": "👩‍🦱",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🦱",
          "searchTerm": [],
        },
        {
          "value": "👩‍🦳",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🦳",
          "searchTerm": [],
        },
        {
          "value": "👩‍🦲",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🦲",
          "searchTerm": [],
        },
        {
          "value": "👱‍♀️",
          "searchTerm": [],
        },
        {
          "value": "👱‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧓",
          "searchTerm": [],
        },
        {
          "value": "👴",
          "searchTerm": [],
        },
        {
          "value": "👵",
          "searchTerm": [],
        },
        {
          "value": "🧏",
          "searchTerm": [],
        },
        {
          "value": "🧏‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧏‍♀️",
          "searchTerm": [],
        },
        {
          "value": "👳",
          "searchTerm": [],
        },
        {
          "value": "👳‍♂️",
          "searchTerm": [],
        },
        {
          "value": "👳‍♀️",
          "searchTerm": [],
        },
        {
          "value": "👲",
          "searchTerm": [],
        },
        {
          "value": "🧕",
          "searchTerm": [],
        },
        {
          "value": "🤰",
          "searchTerm": [],
        },
        {
          "value": "🫃",
          "searchTerm": [],
        },
        {
          "value": "🫄",
          "searchTerm": [],
        },
        {
          "value": "👼",
          "searchTerm": [],
        },
        {
          "value": "🗣️",
          "searchTerm": [],
        },
        {
          "value": "👤",
          "searchTerm": [],
        },
        {
          "value": "👥",
          "searchTerm": [],
        },
        {
          "value": "🦰",
          "searchTerm": [],
        },
        {
          "value": "🦱",
          "searchTerm": [],
        },
        {
          "value": "🦳",
          "searchTerm": [],
        },
        {
          "value": "🦲",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Gestes et expressions",
      "emoji": [
        {
          "value": "🙍‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🙍‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🙎",
          "searchTerm": [],
        },
        {
          "value": "🙎‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🙎‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🙅",
          "searchTerm": [],
        },
        {
          "value": "🙅‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🙅‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🙆",
          "searchTerm": [],
        },
        {
          "value": "🙆‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🙆‍♀️",
          "searchTerm": [],
        },
        {
          "value": "💁",
          "searchTerm": [],
        },
        {
          "value": "💁‍♂️",
          "searchTerm": [],
        },
        {
          "value": "💁‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🙋",
          "searchTerm": [],
        },
        {
          "value": "🙋‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🙋‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧏",
          "searchTerm": [],
        },
        {
          "value": "🧏‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧏‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🙇",
          "searchTerm": [],
        },
        {
          "value": "🙇‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🙇‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🤦",
          "searchTerm": [],
        },
        {
          "value": "🤦‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🤦‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🤷",
          "searchTerm": [],
        },
        {
          "value": "🤷‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🤷‍♀️",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Activités",
      "emoji": [
        {
          "value": "🤱",
          "searchTerm": [],
        },
        {
          "value": "👩‍🍼",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🍼",
          "searchTerm": [],
        },
        {
          "value": "💆",
          "searchTerm": [],
        },
        {
          "value": "💆‍♂️",
          "searchTerm": [],
        },
        {
          "value": "💆‍♀️",
          "searchTerm": [],
        },
        {
          "value": "💇",
          "searchTerm": [],
        },
        {
          "value": "💇‍♂️",
          "searchTerm": [],
        },
        {
          "value": "💇‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🚶",
          "searchTerm": [],
        },
        {
          "value": "🚶‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🚶‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧍",
          "searchTerm": [],
        },
        {
          "value": "🧍‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧍‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧎",
          "searchTerm": [],
        },
        {
          "value": "🧎‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧎‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🦯",
          "searchTerm": [],
        },
        {
          "value": "👨‍🦯",
          "searchTerm": [],
        },
        {
          "value": "👩‍🦯",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🦼",
          "searchTerm": [],
        },
        {
          "value": "👨‍🦼",
          "searchTerm": [],
        },
        {
          "value": "👩‍🦼",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🦽",
          "searchTerm": [],
        },
        {
          "value": "👨‍🦽",
          "searchTerm": [],
        },
        {
          "value": "👩‍🦽",
          "searchTerm": [],
        },
        {
          "value": "🏃",
          "searchTerm": [],
        },
        {
          "value": "🏃‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🏃‍♀️",
          "searchTerm": [],
        },
        {
          "value": "💃",
          "searchTerm": [],
        },
        {
          "value": "🕺",
          "searchTerm": [],
        },
        {
          "value": "🕴️",
          "searchTerm": [],
        },
        {
          "value": "👯",
          "searchTerm": [],
        },
        {
          "value": "👯‍♂️",
          "searchTerm": [],
        },
        {
          "value": "👯‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧖",
          "searchTerm": [],
        },
        {
          "value": "🧖‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧖‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧗",
          "searchTerm": [],
        },
        {
          "value": "🧗‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧗‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🤺",
          "searchTerm": [],
        },
        {
          "value": "🏇",
          "searchTerm": [],
        },
        {
          "value": "⛷️",
          "searchTerm": [],
        },
        {
          "value": "🏂",
          "searchTerm": [],
        },
        {
          "value": "🏌️",
          "searchTerm": [],
        },
        {
          "value": "🏌️‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🏌️‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🏄",
          "searchTerm": [],
        },
        {
          "value": "🏄‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🏄‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🚣",
          "searchTerm": [],
        },
        {
          "value": "🚣‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🚣‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🏊",
          "searchTerm": [],
        },
        {
          "value": "🏊‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🏊‍♀️",
          "searchTerm": [],
        },
        {
          "value": "⛹️",
          "searchTerm": [],
        },
        {
          "value": "⛹️‍♂️",
          "searchTerm": [],
        },
        {
          "value": "⛹️‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🏋️",
          "searchTerm": [],
        },
        {
          "value": "🏋️‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🏋️‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🚴",
          "searchTerm": [],
        },
        {
          "value": "🚴‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🚴‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🚵",
          "searchTerm": [],
        },
        {
          "value": "🚵‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🚵‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🤸",
          "searchTerm": [],
        },
        {
          "value": "🤸‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🤸‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🤼",
          "searchTerm": [],
        },
        {
          "value": "🤼‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🤼‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🤽",
          "searchTerm": [],
        },
        {
          "value": "🤽‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🤽‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🤾",
          "searchTerm": [],
        },
        {
          "value": "🤾‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🤾‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🤹",
          "searchTerm": [],
        },
        {
          "value": "🤹‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🤹‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧘",
          "searchTerm": [],
        },
        {
          "value": "🧘‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧘‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🛀",
          "searchTerm": [],
        },
        {
          "value": "🛌",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Professions, rôles et fantaisies",
      "emoji": [
        {
          "value": "🧑‍⚕️",
          "searchTerm": [],
        },
        {
          "value": "👨‍⚕️",
          "searchTerm": [],
        },
        {
          "value": "👩‍⚕️",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🎓",
          "searchTerm": [],
        },
        {
          "value": "👨‍🎓",
          "searchTerm": [],
        },
        {
          "value": "👩‍🎓",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🏫",
          "searchTerm": [],
        },
        {
          "value": "👨‍🏫",
          "searchTerm": [],
        },
        {
          "value": "👩‍🏫",
          "searchTerm": [],
        },
        {
          "value": "🧑‍⚖️",
          "searchTerm": [],
        },
        {
          "value": "👨‍⚖️",
          "searchTerm": [],
        },
        {
          "value": "👩‍⚖️",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🌾",
          "searchTerm": [],
        },
        {
          "value": "👨‍🌾",
          "searchTerm": [],
        },
        {
          "value": "👩‍🌾",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🍳",
          "searchTerm": [],
        },
        {
          "value": "👨‍🍳",
          "searchTerm": [],
        },
        {
          "value": "👩‍🍳",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🔧",
          "searchTerm": [],
        },
        {
          "value": "👨‍🔧",
          "searchTerm": [],
        },
        {
          "value": "👩‍🔧",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🏭",
          "searchTerm": [],
        },
        {
          "value": "👨‍🏭",
          "searchTerm": [],
        },
        {
          "value": "👩‍🏭",
          "searchTerm": [],
        },
        {
          "value": "🧑‍💼",
          "searchTerm": [],
        },
        {
          "value": "👨‍💼",
          "searchTerm": [],
        },
        {
          "value": "👩‍💼",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🔬",
          "searchTerm": [],
        },
        {
          "value": "👨‍🔬",
          "searchTerm": [],
        },
        {
          "value": "👩‍🔬",
          "searchTerm": [],
        },
        {
          "value": "🧑‍💻",
          "searchTerm": [],
        },
        {
          "value": "👨‍💻",
          "searchTerm": [],
        },
        {
          "value": "👩‍💻",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🎤",
          "searchTerm": [],
        },
        {
          "value": "👨‍🎤",
          "searchTerm": [],
        },
        {
          "value": "👩‍🎤",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🎨",
          "searchTerm": [],
        },
        {
          "value": "👨‍🎨",
          "searchTerm": [],
        },
        {
          "value": "👩‍🎨",
          "searchTerm": [],
        },
        {
          "value": "🧑‍✈️",
          "searchTerm": [],
        },
        {
          "value": "👨‍✈️",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🚀",
          "searchTerm": [],
        },
        {
          "value": "👨‍🚀",
          "searchTerm": [],
        },
        {
          "value": "👩‍🚀",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🚒",
          "searchTerm": [],
        },
        {
          "value": "👨‍🚒",
          "searchTerm": [],
        },
        {
          "value": "👩‍🚒",
          "searchTerm": [],
        },
        {
          "value": "👮",
          "searchTerm": [],
        },
        {
          "value": "👮‍♂️",
          "searchTerm": [],
        },
        {
          "value": "👮‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🕵️",
          "searchTerm": [],
        },
        {
          "value": "🕵️‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🕵️‍♀️",
          "searchTerm": [],
        },
        {
          "value": "💂",
          "searchTerm": [],
        },
        {
          "value": "💂‍♂️",
          "searchTerm": [],
        },
        {
          "value": "💂‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🥷",
          "searchTerm": [],
        },
        {
          "value": "👷",
          "searchTerm": [],
        },
        {
          "value": "👷‍♂️",
          "searchTerm": [],
        },
        {
          "value": "👷‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🫅",
          "searchTerm": [],
        },
        {
          "value": "🤴",
          "searchTerm": [],
        },
        {
          "value": "👸",
          "searchTerm": [],
        },
        {
          "value": "🤵",
          "searchTerm": [],
        },
        {
          "value": "🤵‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🤵‍♀️",
          "searchTerm": [],
        },
        {
          "value": "👰",
          "searchTerm": [],
        },
        {
          "value": "👰‍♂️",
          "searchTerm": [],
        },
        {
          "value": "👰‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🎅",
          "searchTerm": [],
        },
        {
          "value": "🤶",
          "searchTerm": [],
        },
        {
          "value": "🧑‍🎄",
          "searchTerm": [],
        },
        {
          "value": "🦸",
          "searchTerm": [],
        },
        {
          "value": "🦸‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🦸‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🦹",
          "searchTerm": [],
        },
        {
          "value": "🦹‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🦹‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧙",
          "searchTerm": [],
        },
        {
          "value": "🧙‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧙‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧚",
          "searchTerm": [],
        },
        {
          "value": "🧚‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧚‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧛",
          "searchTerm": [],
        },
        {
          "value": "🧛‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧛‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧜",
          "searchTerm": [],
        },
        {
          "value": "🧜‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧜‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧝",
          "searchTerm": [],
        },
        {
          "value": "🧝‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧝‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧞",
          "searchTerm": [],
        },
        {
          "value": "🧞‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧞‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧟",
          "searchTerm": [],
        },
        {
          "value": "🧟‍♂️",
          "searchTerm": [],
        },
        {
          "value": "🧟‍♀️",
          "searchTerm": [],
        },
        {
          "value": "🧌",
          "searchTerm": [],
        },
        {
          "value": "👯",
          "searchTerm": [],
        },
        {
          "value": "👯‍♂️",
          "searchTerm": [],
        },
        {
          "value": "👯‍♀️",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Familles et couples",
      "emoji": [
        {
          "value": "🧑‍🤝‍🧑",
          "searchTerm": [],
        },
        {
          "value": "👭",
          "searchTerm": [],
        },
        {
          "value": "👫",
          "searchTerm": [],
        },
        {
          "value": "👬",
          "searchTerm": [],
        },
        {
          "value": "💏",
          "searchTerm": [],
        },
        {
          "value": "👩‍❤️‍💋‍👨",
          "searchTerm": [],
        },
        {
          "value": "👨‍❤️‍💋‍👨",
          "searchTerm": [],
        },
        {
          "value": "👩‍❤️‍💋‍👩",
          "searchTerm": [],
        },
        {
          "value": "💑",
          "searchTerm": [],
        },
        {
          "value": "👩‍❤️‍👨",
          "searchTerm": [],
        },
        {
          "value": "👨‍❤️‍👨",
          "searchTerm": [],
        },
        {
          "value": "👩‍❤️‍👩",
          "searchTerm": [],
        },
        {
          "value": "👪",
          "searchTerm": [],
        },
        {
          "value": "👨‍👩‍👦",
          "searchTerm": [],
        },
        {
          "value": "👨‍👩‍👧",
          "searchTerm": [],
        },
        {
          "value": "👨‍👩‍👧‍👦",
          "searchTerm": [],
        },
        {
          "value": "👨‍👩‍👦‍👦",
          "searchTerm": [],
        },
        {
          "value": "👨‍👩‍👧‍👧",
          "searchTerm": [],
        },
        {
          "value": "👨‍👨‍👦",
          "searchTerm": [],
        },
        {
          "value": "👨‍👨‍👧",
          "searchTerm": [],
        },
        {
          "value": "👨‍👨‍👧‍👦",
          "searchTerm": [],
        },
        {
          "value": "👨‍👨‍👦‍👦",
          "searchTerm": [],
        },
        {
          "value": "👨‍👨‍👧‍👧",
          "searchTerm": [],
        },
        {
          "value": "👩‍👩‍👦",
          "searchTerm": [],
        },
        {
          "value": "👩‍👩‍👧",
          "searchTerm": [],
        },
        {
          "value": "👩‍👩‍👧‍👦",
          "searchTerm": [],
        },
        {
          "value": "👩‍👩‍👦‍👦",
          "searchTerm": [],
        },
        {
          "value": "👩‍👩‍👧‍👧",
          "searchTerm": [],
        },
        {
          "value": "👨‍👦",
          "searchTerm": [],
        },
        {
          "value": "👨‍👦‍👦",
          "searchTerm": [],
        },
        {
          "value": "👨‍👧",
          "searchTerm": [],
        },
        {
          "value": "👨‍👧‍👦",
          "searchTerm": [],
        },
        {
          "value": "👨‍👧‍👧",
          "searchTerm": [],
        },
        {
          "value": "👩‍👦",
          "searchTerm": [],
        },
        {
          "value": "👩‍👦‍👦",
          "searchTerm": [],
        },
        {
          "value": "👩‍👧",
          "searchTerm": [],
        },
        {
          "value": "👩‍👧‍👦",
          "searchTerm": [],
        },
        {
          "value": "👩‍👧‍👧",
          "searchTerm": [],
        },
        {
          "value": "👩‍👨‍👧‍👧",
          "searchTerm": [],
        },
        {
          "value": "👩‍👨‍👦‍👧",
          "searchTerm": [],
        },
        {
          "value": "👨‍👩‍👦‍👧",
          "searchTerm": [],
        },
        {
          "value": "👩‍👨‍👦‍👦",
          "searchTerm": [],
        },
        {
          "value": "👨‍👦‍👧",
          "searchTerm": [],
        },
        {
          "value": "👩‍👨‍👧",
          "searchTerm": [],
        },
        {
          "value": "👩‍👨‍👦",
          "searchTerm": [],
        },
        {
          "value": "👩‍👦‍👧",
          "searchTerm": [],
        },
        {
          "value": "👩‍👩‍👦‍👧",
          "searchTerm": [],
        },
        {
          "value": "👨‍👨‍👦‍👧",
          "searchTerm": [],
        },
        {
          "value": "👩‍👨‍👧‍👦",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Mammifères et marsupiaux",
      "emoji": [
        {
          "value": "🐵",
          "searchTerm": [],
        },
        {
          "value": "🐒",
          "searchTerm": [],
        },
        {
          "value": "🦍",
          "searchTerm": [],
        },
        {
          "value": "🦧",
          "searchTerm": [],
        },
        {
          "value": "🐶",
          "searchTerm": [],
        },
        {
          "value": "🐕",
          "searchTerm": [],
        },
        {
          "value": "🦮",
          "searchTerm": [],
        },
        {
          "value": "🐕‍🦺",
          "searchTerm": [],
        },
        {
          "value": "🐩",
          "searchTerm": [],
        },
        {
          "value": "🐺",
          "searchTerm": [],
        },
        {
          "value": "🦊",
          "searchTerm": [],
        },
        {
          "value": "🦝",
          "searchTerm": [],
        },
        {
          "value": "🐱",
          "searchTerm": [],
        },
        {
          "value": "🐈",
          "searchTerm": [],
        },
        {
          "value": "🐈‍⬛",
          "searchTerm": [],
        },
        {
          "value": "🦁",
          "searchTerm": [],
        },
        {
          "value": "🐯",
          "searchTerm": [],
        },
        {
          "value": "🐅",
          "searchTerm": [],
        },
        {
          "value": "🐆",
          "searchTerm": [],
        },
        {
          "value": "🐴",
          "searchTerm": [],
        },
        {
          "value": "🐎",
          "searchTerm": [],
        },
        {
          "value": "🦄",
          "searchTerm": [],
        },
        {
          "value": "🦓",
          "searchTerm": [],
        },
        {
          "value": "🫏",
          "searchTerm": [],
        },
        {
          "value": "🦌",
          "searchTerm": [],
        },
        {
          "value": "🫎",
          "searchTerm": [],
        },
        {
          "value": "🦬",
          "searchTerm": [],
        },
        {
          "value": "🐮",
          "searchTerm": [],
        },
        {
          "value": "🐂",
          "searchTerm": [],
        },
        {
          "value": "🐃",
          "searchTerm": [],
        },
        {
          "value": "🐄",
          "searchTerm": [],
        },
        {
          "value": "🐷",
          "searchTerm": [],
        },
        {
          "value": "🐖",
          "searchTerm": [],
        },
        {
          "value": "🐗",
          "searchTerm": [],
        },
        {
          "value": "🐽",
          "searchTerm": [],
        },
        {
          "value": "🐏",
          "searchTerm": [],
        },
        {
          "value": "🐑",
          "searchTerm": [],
        },
        {
          "value": "🐐",
          "searchTerm": [],
        },
        {
          "value": "🐪",
          "searchTerm": [],
        },
        {
          "value": "🐫",
          "searchTerm": [],
        },
        {
          "value": "🦙",
          "searchTerm": [],
        },
        {
          "value": "🦒",
          "searchTerm": [],
        },
        {
          "value": "🐘",
          "searchTerm": [],
        },
        {
          "value": "🦣",
          "searchTerm": [],
        },
        {
          "value": "🦏",
          "searchTerm": [],
        },
        {
          "value": "🦛",
          "searchTerm": [],
        },
        {
          "value": "🐭",
          "searchTerm": [],
        },
        {
          "value": "🐁",
          "searchTerm": [],
        },
        {
          "value": "🐀",
          "searchTerm": [],
        },
        {
          "value": "🐹",
          "searchTerm": [],
        },
        {
          "value": "🐰",
          "searchTerm": [],
        },
        {
          "value": "🐇",
          "searchTerm": [],
        },
        {
          "value": "🐿️",
          "searchTerm": [],
        },
        {
          "value": "🦫",
          "searchTerm": [],
        },
        {
          "value": "🦔",
          "searchTerm": [],
        },
        {
          "value": "🦇",
          "searchTerm": [],
        },
        {
          "value": "🐻",
          "searchTerm": [],
        },
        {
          "value": "🐻‍❄️",
          "searchTerm": [],
        },
        {
          "value": "🐨",
          "searchTerm": [],
        },
        {
          "value": "🐼",
          "searchTerm": [],
        },
        {
          "value": "🦥",
          "searchTerm": [],
        },
        {
          "value": "🦦",
          "searchTerm": [],
        },
        {
          "value": "🦨",
          "searchTerm": [],
        },
        {
          "value": "🦘",
          "searchTerm": [],
        },
        {
          "value": "🦡",
          "searchTerm": [],
        },
        {
          "value": "🐾",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Oiseaux",
      "emoji": [
        {
          "value": "🦃",
          "searchTerm": [],
        },
        {
          "value": "🐔",
          "searchTerm": [],
        },
        {
          "value": "🐓",
          "searchTerm": [],
        },
        {
          "value": "🐣",
          "searchTerm": [],
        },
        {
          "value": "🐤",
          "searchTerm": [],
        },
        {
          "value": "🐥",
          "searchTerm": [],
        },
        {
          "value": "🐦",
          "searchTerm": [],
        },
        {
          "value": "🐦‍⬛",
          "searchTerm": [],
        },
        {
          "value": "🐧",
          "searchTerm": [],
        },
        {
          "value": "🕊️",
          "searchTerm": [],
        },
        {
          "value": "🦅",
          "searchTerm": [],
        },
        {
          "value": "🦆",
          "searchTerm": [],
        },
        {
          "value": "🦢",
          "searchTerm": [],
        },
        {
          "value": "🪿",
          "searchTerm": [],
        },
        {
          "value": "🦉",
          "searchTerm": [],
        },
        {
          "value": "🦤",
          "searchTerm": [],
        },
        {
          "value": "🪽",
          "searchTerm": [],
        },
        {
          "value": "🪶",
          "searchTerm": [],
        },
        {
          "value": "🦩",
          "searchTerm": [],
        },
        {
          "value": "🦚",
          "searchTerm": [],
        },
        {
          "value": "🦜",
          "searchTerm": [],
        },
        {
          "value": "🪹",
          "searchTerm": [],
        },
        {
          "value": "🪺",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Marins et reptiles",
      "emoji": [
        {
          "value": "🐸",
          "searchTerm": [],
        },
        {
          "value": "🐊",
          "searchTerm": [],
        },
        {
          "value": "🐢",
          "searchTerm": [],
        },
        {
          "value": "🦎",
          "searchTerm": [],
        },
        {
          "value": "🐍",
          "searchTerm": [],
        },
        {
          "value": "🐲",
          "searchTerm": [],
        },
        {
          "value": "🐉",
          "searchTerm": [],
        },
        {
          "value": "🦕",
          "searchTerm": [],
        },
        {
          "value": "🦖",
          "searchTerm": [],
        },
        {
          "value": "🐳",
          "searchTerm": [],
        },
        {
          "value": "🐋",
          "searchTerm": [],
        },
        {
          "value": "🐬",
          "searchTerm": [],
        },
        {
          "value": "🦭",
          "searchTerm": [],
        },
        {
          "value": "🐟",
          "searchTerm": [],
        },
        {
          "value": "🐠",
          "searchTerm": [],
        },
        {
          "value": "🐡",
          "searchTerm": [],
        },
        {
          "value": "🦈",
          "searchTerm": [],
        },
        {
          "value": "🐙",
          "searchTerm": [],
        },
        {
          "value": "🪼",
          "searchTerm": [],
        },
        {
          "value": "🐚",
          "searchTerm": [],
        },
        {
          "value": "🪸",
          "searchTerm": [],
        },
        {
          "value": "🦀",
          "searchTerm": [],
        },
        {
          "value": "🦞",
          "searchTerm": [],
        },
        {
          "value": "🦐",
          "searchTerm": [],
        },
        {
          "value": "🦑",
          "searchTerm": [],
        },
        {
          "value": "🦪",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Insectes",
      "emoji": [
        {
          "value": "🐌",
          "searchTerm": [],
        },
        {
          "value": "🦋",
          "searchTerm": [],
        },
        {
          "value": "🐛",
          "searchTerm": [],
        },
        {
          "value": "🐜",
          "searchTerm": [],
        },
        {
          "value": "🐝",
          "searchTerm": [],
        },
        {
          "value": "🪲",
          "searchTerm": [],
        },
        {
          "value": "🐞",
          "searchTerm": [],
        },
        {
          "value": "🦗",
          "searchTerm": [],
        },
        {
          "value": "🪳",
          "searchTerm": [],
        },
        {
          "value": "🕷️",
          "searchTerm": [],
        },
        {
          "value": "🕸️",
          "searchTerm": [],
        },
        {
          "value": "🦂",
          "searchTerm": [],
        },
        {
          "value": "🦟",
          "searchTerm": [],
        },
        {
          "value": "🪰",
          "searchTerm": [],
        },
        {
          "value": "🪱",
          "searchTerm": [],
        },
        {
          "value": "🦠",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Plantes, fleurs et nature",
      "emoji": [
        {
          "value": "💐",
          "searchTerm": [],
        },
        {
          "value": "🌸",
          "searchTerm": [],
        },
        {
          "value": "💮",
          "searchTerm": [],
        },
        {
          "value": "🪷",
          "searchTerm": [],
        },
        {
          "value": "🏵️",
          "searchTerm": [],
        },
        {
          "value": "🌹",
          "searchTerm": [],
        },
        {
          "value": "🥀",
          "searchTerm": [],
        },
        {
          "value": "🌺",
          "searchTerm": [],
        },
        {
          "value": "🪻",
          "searchTerm": [],
        },
        {
          "value": "🌻",
          "searchTerm": [],
        },
        {
          "value": "🌼",
          "searchTerm": [],
        },
        {
          "value": "🌷",
          "searchTerm": [],
        },
        {
          "value": "🌱",
          "searchTerm": [],
        },
        {
          "value": "🪴",
          "searchTerm": [],
        },
        {
          "value": "🌲",
          "searchTerm": [],
        },
        {
          "value": "🌳",
          "searchTerm": [],
        },
        {
          "value": "🌴",
          "searchTerm": [],
        },
        {
          "value": "🌵",
          "searchTerm": [],
        },
        {
          "value": "🌾",
          "searchTerm": [],
        },
        {
          "value": "🌿",
          "searchTerm": [],
        },
        {
          "value": "☘️",
          "searchTerm": [],
        },
        {
          "value": "🍀",
          "searchTerm": [],
        },
        {
          "value": "🍁",
          "searchTerm": [],
        },
        {
          "value": "🍂",
          "searchTerm": [],
        },
        {
          "value": "🍃",
          "searchTerm": [],
        },
        {
          "value": "🍄",
          "searchTerm": [],
        },
        {
          "value": "🪨",
          "searchTerm": [],
        },
        {
          "value": "🪵",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Ciel et météo",
      "emoji": [
        {
          "value": "❤️‍🔥",
          "searchTerm": [],
        },
        {
          "value": "🌑",
          "searchTerm": [],
        },
        {
          "value": "🌒",
          "searchTerm": [],
        },
        {
          "value": "🌓",
          "searchTerm": [],
        },
        {
          "value": "🌔",
          "searchTerm": [],
        },
        {
          "value": "🌕",
          "searchTerm": [],
        },
        {
          "value": "🌖",
          "searchTerm": [],
        },
        {
          "value": "🌗",
          "searchTerm": [],
        },
        {
          "value": "🌘",
          "searchTerm": [],
        },
        {
          "value": "🌙",
          "searchTerm": [],
        },
        {
          "value": "🌚",
          "searchTerm": [],
        },
        {
          "value": "🌛",
          "searchTerm": [],
        },
        {
          "value": "🌜",
          "searchTerm": [],
        },
        {
          "value": "☀️",
          "searchTerm": [],
        },
        {
          "value": "🌝",
          "searchTerm": [],
        },
        {
          "value": "🌞",
          "searchTerm": [],
        },
        {
          "value": "🪐",
          "searchTerm": [],
        },
        {
          "value": "⭐",
          "searchTerm": [],
        },
        {
          "value": "🌟",
          "searchTerm": [],
        },
        {
          "value": "🌠",
          "searchTerm": [],
        },
        {
          "value": "🌌",
          "searchTerm": [],
        },
        {
          "value": "☁️",
          "searchTerm": [],
        },
        {
          "value": "⛅",
          "searchTerm": [],
        },
        {
          "value": "⛈️",
          "searchTerm": [],
        },
        {
          "value": "🌤️",
          "searchTerm": [],
        },
        {
          "value": "🌥️",
          "searchTerm": [],
        },
        {
          "value": "🌦️",
          "searchTerm": [],
        },
        {
          "value": "🌧️",
          "searchTerm": [],
        },
        {
          "value": "🌨️",
          "searchTerm": [],
        },
        {
          "value": "🌩️",
          "searchTerm": [],
        },
        {
          "value": "🌪️",
          "searchTerm": [],
        },
        {
          "value": "🌫️",
          "searchTerm": [],
        },
        {
          "value": "🌬️",
          "searchTerm": [],
        },
        {
          "value": "🌀",
          "searchTerm": [],
        },
        {
          "value": "🌈",
          "searchTerm": [],
        },
        {
          "value": "🌂",
          "searchTerm": [],
        },
        {
          "value": "☂️",
          "searchTerm": [],
        },
        {
          "value": "☔",
          "searchTerm": [],
        },
        {
          "value": "⛱️",
          "searchTerm": [],
        },
        {
          "value": "⚡",
          "searchTerm": [],
        },
        {
          "value": "❄️",
          "searchTerm": [],
        },
        {
          "value": "☃️",
          "searchTerm": [],
        },
        {
          "value": "⛄",
          "searchTerm": [],
        },
        {
          "value": "☄️",
          "searchTerm": [],
        },
        {
          "value": "💧",
          "searchTerm": [],
        },
        {
          "value": "🌊",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Fruits",
      "emoji": [
        {
          "value": "🍇",
          "searchTerm": [],
        },
        {
          "value": "🍈",
          "searchTerm": [],
        },
        {
          "value": "🍉",
          "searchTerm": [],
        },
        {
          "value": "🍊",
          "searchTerm": [],
        },
        {
          "value": "🍋",
          "searchTerm": [],
        },
        {
          "value": "🍌",
          "searchTerm": [],
        },
        {
          "value": "🍍",
          "searchTerm": [],
        },
        {
          "value": "🥭",
          "searchTerm": [],
        },
        {
          "value": "🍎",
          "searchTerm": [],
        },
        {
          "value": "🍏",
          "searchTerm": [],
        },
        {
          "value": "🍐",
          "searchTerm": [],
        },
        {
          "value": "🍑",
          "searchTerm": [],
        },
        {
          "value": "🍒",
          "searchTerm": [],
        },
        {
          "value": "🍓",
          "searchTerm": [],
        },
        {
          "value": "🫐",
          "searchTerm": [],
        },
        {
          "value": "🥝",
          "searchTerm": [],
        },
        {
          "value": "🍅",
          "searchTerm": [],
        },
        {
          "value": "🫒",
          "searchTerm": [],
        },
        {
          "value": "🥥",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Légumes",
      "emoji": [
        {
          "value": "🥑",
          "searchTerm": [],
        },
        {
          "value": "🍆",
          "searchTerm": [],
        },
        {
          "value": "🥔",
          "searchTerm": [],
        },
        {
          "value": "🥕",
          "searchTerm": [],
        },
        {
          "value": "🌽",
          "searchTerm": [],
        },
        {
          "value": "🌶️",
          "searchTerm": [],
        },
        {
          "value": "🫑",
          "searchTerm": [],
        },
        {
          "value": "🥒",
          "searchTerm": [],
        },
        {
          "value": "🥬",
          "searchTerm": [],
        },
        {
          "value": "🥦",
          "searchTerm": [],
        },
        {
          "value": "🫛",
          "searchTerm": [],
        },
        {
          "value": "🧄",
          "searchTerm": [],
        },
        {
          "value": "🧅",
          "searchTerm": [],
        },
        {
          "value": "🫚",
          "searchTerm": [],
        },
        {
          "value": "🥜",
          "searchTerm": [],
        },
        {
          "value": "🫘",
          "searchTerm": [],
        },
        {
          "value": "🌰",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Aliments préparés",
      "emoji": [
        {
          "value": "🍞",
          "searchTerm": [],
        },
        {
          "value": "🥐",
          "searchTerm": [],
        },
        {
          "value": "🥖",
          "searchTerm": [],
        },
        {
          "value": "🫓",
          "searchTerm": [],
        },
        {
          "value": "🥨",
          "searchTerm": [],
        },
        {
          "value": "🥯",
          "searchTerm": [],
        },
        {
          "value": "🥞",
          "searchTerm": [],
        },
        {
          "value": "🧇",
          "searchTerm": [],
        },
        {
          "value": "🧀",
          "searchTerm": [],
        },
        {
          "value": "🍖",
          "searchTerm": [],
        },
        {
          "value": "🍗",
          "searchTerm": [],
        },
        {
          "value": "🥩",
          "searchTerm": [],
        },
        {
          "value": "🥓",
          "searchTerm": [],
        },
        {
          "value": "🍔",
          "searchTerm": [],
        },
        {
          "value": "🍟",
          "searchTerm": [],
        },
        {
          "value": "🍕",
          "searchTerm": [],
        },
        {
          "value": "🌭",
          "searchTerm": [],
        },
        {
          "value": "🥪",
          "searchTerm": [],
        },
        {
          "value": "🌮",
          "searchTerm": [],
        },
        {
          "value": "🌯",
          "searchTerm": [],
        },
        {
          "value": "🫔",
          "searchTerm": [],
        },
        {
          "value": "🥙",
          "searchTerm": [],
        },
        {
          "value": "🧆",
          "searchTerm": [],
        },
        {
          "value": "🥚",
          "searchTerm": [],
        },
        {
          "value": "🍳",
          "searchTerm": [],
        },
        {
          "value": "🥘",
          "searchTerm": [],
        },
        {
          "value": "🍲",
          "searchTerm": [],
        },
        {
          "value": "🫕",
          "searchTerm": [],
        },
        {
          "value": "🥣",
          "searchTerm": [],
        },
        {
          "value": "🥗",
          "searchTerm": [],
        },
        {
          "value": "🍿",
          "searchTerm": [],
        },
        {
          "value": "🧈",
          "searchTerm": [],
        },
        {
          "value": "🧂",
          "searchTerm": [],
        },
        {
          "value": "🥫",
          "searchTerm": [],
        },
        {
          "value": "🍝",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Aliments asiatique",
      "emoji": [
        {
          "value": "🍱",
          "searchTerm": [],
        },
        {
          "value": "🍘",
          "searchTerm": [],
        },
        {
          "value": "🍙",
          "searchTerm": [],
        },
        {
          "value": "🍚",
          "searchTerm": [],
        },
        {
          "value": "🍛",
          "searchTerm": [],
        },
        {
          "value": "🍜",
          "searchTerm": [],
        },
        {
          "value": "🍠",
          "searchTerm": [],
        },
        {
          "value": "🍢",
          "searchTerm": [],
        },
        {
          "value": "🍣",
          "searchTerm": [],
        },
        {
          "value": "🍤",
          "searchTerm": [],
        },
        {
          "value": "🍥",
          "searchTerm": [],
        },
        {
          "value": "🥮",
          "searchTerm": [],
        },
        {
          "value": "🍡",
          "searchTerm": [],
        },
        {
          "value": "🥟",
          "searchTerm": [],
        },
        {
          "value": "🥠",
          "searchTerm": [],
        },
        {
          "value": "🥡",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Dessert et sucreries",
      "emoji": [
        {
          "value": "🍦",
          "searchTerm": [],
        },
        {
          "value": "🍧",
          "searchTerm": [],
        },
        {
          "value": "🍨",
          "searchTerm": [],
        },
        {
          "value": "🍩",
          "searchTerm": [],
        },
        {
          "value": "🍪",
          "searchTerm": [],
        },
        {
          "value": "🎂",
          "searchTerm": [],
        },
        {
          "value": "🍰",
          "searchTerm": [],
        },
        {
          "value": "🧁",
          "searchTerm": [],
        },
        {
          "value": "🥧",
          "searchTerm": [],
        },
        {
          "value": "🍫",
          "searchTerm": [],
        },
        {
          "value": "🍬",
          "searchTerm": [],
        },
        {
          "value": "🍭",
          "searchTerm": [],
        },
        {
          "value": "🍮",
          "searchTerm": [],
        },
        {
          "value": "🍯",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Boissons et couverts",
      "emoji": [
        {
          "value": "🍼",
          "searchTerm": [],
        },
        {
          "value": "🥛",
          "searchTerm": [],
        },
        {
          "value": "☕",
          "searchTerm": [],
        },
        {
          "value": "🫖",
          "searchTerm": [],
        },
        {
          "value": "🍵",
          "searchTerm": [],
        },
        {
          "value": "🍶",
          "searchTerm": [],
        },
        {
          "value": "🍾",
          "searchTerm": [],
        },
        {
          "value": "🍷",
          "searchTerm": [],
        },
        {
          "value": "🍸",
          "searchTerm": [],
        },
        {
          "value": "🍹",
          "searchTerm": [],
        },
        {
          "value": "🍺",
          "searchTerm": [],
        },
        {
          "value": "🍻",
          "searchTerm": [],
        },
        {
          "value": "🥂",
          "searchTerm": [],
        },
        {
          "value": "🥃",
          "searchTerm": [],
        },
        {
          "value": "🫗",
          "searchTerm": [],
        },
        {
          "value": "🥤",
          "searchTerm": [],
        },
        {
          "value": "🧋",
          "searchTerm": [],
        },
        {
          "value": "🧃",
          "searchTerm": [],
        },
        {
          "value": "🧉",
          "searchTerm": [],
        },
        {
          "value": "🥢",
          "searchTerm": [],
        },
        {
          "value": "🍽️",
          "searchTerm": [],
        },
        {
          "value": "🍴",
          "searchTerm": [],
        },
        {
          "value": "🥄",
          "searchTerm": [],
        },
        {
          "value": "🔪",
          "searchTerm": [],
        },
        {
          "value": "🫙",
          "searchTerm": [],
        },
        {
          "value": "🏺",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Évènements",
      "emoji": [
        {
          "value": "🎃",
          "searchTerm": [],
        },
        {
          "value": "🎄",
          "searchTerm": [],
        },
        {
          "value": "🎆",
          "searchTerm": [],
        },
        {
          "value": "🎇",
          "searchTerm": [],
        },
        {
          "value": "🧨",
          "searchTerm": [],
        },
        {
          "value": "✨",
          "searchTerm": [],
        },
        {
          "value": "🎈",
          "searchTerm": [],
        },
        {
          "value": "🎉",
          "searchTerm": [],
        },
        {
          "value": "🎊",
          "searchTerm": [],
        },
        {
          "value": "🎋",
          "searchTerm": [],
        },
        {
          "value": "🎍",
          "searchTerm": [],
        },
        {
          "value": "🎎",
          "searchTerm": [],
        },
        {
          "value": "🎏",
          "searchTerm": [],
        },
        {
          "value": "🎐",
          "searchTerm": [],
        },
        {
          "value": "🎑",
          "searchTerm": [],
        },
        {
          "value": "🧧",
          "searchTerm": [],
        },
        {
          "value": "🎁",
          "searchTerm": [],
        },
        {
          "value": "🎟️",
          "searchTerm": [],
        },
        {
          "value": "🎫",
          "searchTerm": [],
        },
        {
          "value": "🏮",
          "searchTerm": [],
        },
        {
          "value": "🪔",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Sports et récompenses",
      "emoji": [
        {
          "value": "🎖️",
          "searchTerm": [],
        },
        {
          "value": "🏆",
          "searchTerm": [],
        },
        {
          "value": "🏅",
          "searchTerm": [],
        },
        {
          "value": "🥇",
          "searchTerm": [],
        },
        {
          "value": "🥈",
          "searchTerm": [],
        },
        {
          "value": "🥉",
          "searchTerm": [],
        },
        {
          "value": "⚽",
          "searchTerm": [],
        },
        {
          "value": "⚾",
          "searchTerm": [],
        },
        {
          "value": "🥎",
          "searchTerm": [],
        },
        {
          "value": "🏀",
          "searchTerm": [],
        },
        {
          "value": "🏐",
          "searchTerm": [],
        },
        {
          "value": "🏈",
          "searchTerm": [],
        },
        {
          "value": "🏉",
          "searchTerm": [],
        },
        {
          "value": "🎾",
          "searchTerm": [],
        },
        {
          "value": "🥏",
          "searchTerm": [],
        },
        {
          "value": "🎳",
          "searchTerm": [],
        },
        {
          "value": "🏏",
          "searchTerm": [],
        },
        {
          "value": "🏑",
          "searchTerm": [],
        },
        {
          "value": "🏒",
          "searchTerm": [],
        },
        {
          "value": "🥍",
          "searchTerm": [],
        },
        {
          "value": "🏓",
          "searchTerm": [],
        },
        {
          "value": "🏸",
          "searchTerm": [],
        },
        {
          "value": "🥊",
          "searchTerm": [],
        },
        {
          "value": "🥋",
          "searchTerm": [],
        },
        {
          "value": "🥅",
          "searchTerm": [],
        },
        {
          "value": "⛳",
          "searchTerm": [],
        },
        {
          "value": "⛸️",
          "searchTerm": [],
        },
        {
          "value": "🎣",
          "searchTerm": [],
        },
        {
          "value": "🤿",
          "searchTerm": [],
        },
        {
          "value": "🎽",
          "searchTerm": [],
        },
        {
          "value": "🎿",
          "searchTerm": [],
        },
        {
          "value": "🛷",
          "searchTerm": [],
        },
        {
          "value": "🥌",
          "searchTerm": [],
        },
        {
          "value": "🎯",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Jeux et culture",
      "emoji": [
        {
          "value": "🪀",
          "searchTerm": [],
        },
        {
          "value": "🪁",
          "searchTerm": [],
        },
        {
          "value": "🎱",
          "searchTerm": [],
        },
        {
          "value": "🔮",
          "searchTerm": [],
        },
        {
          "value": "🪄",
          "searchTerm": [],
        },
        {
          "value": "🎮",
          "searchTerm": [],
        },
        {
          "value": "🕹️",
          "searchTerm": [],
        },
        {
          "value": "🎰",
          "searchTerm": [],
        },
        {
          "value": "🎲",
          "searchTerm": [],
        },
        {
          "value": "🧩",
          "searchTerm": [],
        },
        {
          "value": "🪅",
          "searchTerm": [],
        },
        {
          "value": "🪩",
          "searchTerm": [],
        },
        {
          "value": "🪆",
          "searchTerm": [],
        },
        {
          "value": "♠️",
          "searchTerm": [],
        },
        {
          "value": "♥️",
          "searchTerm": [],
        },
        {
          "value": "♦️",
          "searchTerm": [],
        },
        {
          "value": "♣️",
          "searchTerm": [],
        },
        {
          "value": "♟️",
          "searchTerm": [],
        },
        {
          "value": "🃏",
          "searchTerm": [],
        },
        {
          "value": "🀄",
          "searchTerm": [],
        },
        {
          "value": "🎴",
          "searchTerm": [],
        },
        {
          "value": "🎭",
          "searchTerm": [],
        },
        {
          "value": "🖼️",
          "searchTerm": [],
        },
        {
          "value": "🎨",
          "searchTerm": [],
        },
        {
          "value": "🔫",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Carte et géographie",
      "emoji": [
        {
          "value": "🌍",
          "searchTerm": [],
        },
        {
          "value": "🌎",
          "searchTerm": [],
        },
        {
          "value": "🌏",
          "searchTerm": [],
        },
        {
          "value": "🌐",
          "searchTerm": [],
        },
        {
          "value": "🗺️",
          "searchTerm": [],
        },
        {
          "value": "🗾",
          "searchTerm": [],
        },
        {
          "value": "🧭",
          "searchTerm": [],
        },
        {
          "value": "🏔️",
          "searchTerm": [],
        },
        {
          "value": "⛰️",
          "searchTerm": [],
        },
        {
          "value": "🌋",
          "searchTerm": [],
        },
        {
          "value": "🗻",
          "searchTerm": [],
        },
        {
          "value": "🏕️",
          "searchTerm": [],
        },
        {
          "value": "🏖️",
          "searchTerm": [],
        },
        {
          "value": "🏜️",
          "searchTerm": [],
        },
        {
          "value": "🏝️",
          "searchTerm": [],
        },
        {
          "value": "🏞️",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Bâtiments et lieux",
      "emoji": [
        {
          "value": "🏟️",
          "searchTerm": [],
        },
        {
          "value": "🏛️",
          "searchTerm": [],
        },
        {
          "value": "🏗️",
          "searchTerm": [],
        },
        {
          "value": "🧱",
          "searchTerm": [],
        },
        {
          "value": "🛖",
          "searchTerm": [],
        },
        {
          "value": "🏘️",
          "searchTerm": [],
        },
        {
          "value": "🏚️",
          "searchTerm": [],
        },
        {
          "value": "🏠",
          "searchTerm": [],
        },
        {
          "value": "🏡",
          "searchTerm": [],
        },
        {
          "value": "🏢",
          "searchTerm": [],
        },
        {
          "value": "🏣",
          "searchTerm": [],
        },
        {
          "value": "🏤",
          "searchTerm": [],
        },
        {
          "value": "🏥",
          "searchTerm": [],
        },
        {
          "value": "🏦",
          "searchTerm": [],
        },
        {
          "value": "🏨",
          "searchTerm": [],
        },
        {
          "value": "🏩",
          "searchTerm": [],
        },
        {
          "value": "🏪",
          "searchTerm": [],
        },
        {
          "value": "🏫",
          "searchTerm": [],
        },
        {
          "value": "🏬",
          "searchTerm": [],
        },
        {
          "value": "🏭",
          "searchTerm": [],
        },
        {
          "value": "🏯",
          "searchTerm": [],
        },
        {
          "value": "🏰",
          "searchTerm": [],
        },
        {
          "value": "💒",
          "searchTerm": [],
        },
        {
          "value": "🗼",
          "searchTerm": [],
        },
        {
          "value": "🗽",
          "searchTerm": [],
        },
        {
          "value": "⛪",
          "searchTerm": [],
        },
        {
          "value": "🕌",
          "searchTerm": [],
        },
        {
          "value": "🛕",
          "searchTerm": [],
        },
        {
          "value": "🕍",
          "searchTerm": [],
        },
        {
          "value": "⛩️",
          "searchTerm": [],
        },
        {
          "value": "🕋",
          "searchTerm": [],
        },
        {
          "value": "⛲",
          "searchTerm": [],
        },
        {
          "value": "⛺",
          "searchTerm": [],
        },
        {
          "value": "🌁",
          "searchTerm": [],
        },
        {
          "value": "🌃",
          "searchTerm": [],
        },
        {
          "value": "🏙️",
          "searchTerm": [],
        },
        {
          "value": "🌄",
          "searchTerm": [],
        },
        {
          "value": "🌅",
          "searchTerm": [],
        },
        {
          "value": "🌆",
          "searchTerm": [],
        },
        {
          "value": "🌇",
          "searchTerm": [],
        },
        {
          "value": "🌉",
          "searchTerm": [],
        },
        {
          "value": "♨️",
          "searchTerm": [],
        },
        {
          "value": "🎠",
          "searchTerm": [],
        },
        {
          "value": "🛝",
          "searchTerm": [],
        },
        {
          "value": "🎡",
          "searchTerm": [],
        },
        {
          "value": "🎢",
          "searchTerm": [],
        },
        {
          "value": "💈",
          "searchTerm": [],
        },
        {
          "value": "🎪",
          "searchTerm": [],
        },
        {
          "value": "🛎️",
          "searchTerm": [],
        },
        {
          "value": "🗿",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Transports",
      "emoji": [
        {
          "value": "🚂",
          "searchTerm": [],
        },
        {
          "value": "🚃",
          "searchTerm": [],
        },
        {
          "value": "🚄",
          "searchTerm": [],
        },
        {
          "value": "🚅",
          "searchTerm": [],
        },
        {
          "value": "🚆",
          "searchTerm": [],
        },
        {
          "value": "🚇",
          "searchTerm": [],
        },
        {
          "value": "🚈",
          "searchTerm": [],
        },
        {
          "value": "🚉",
          "searchTerm": [],
        },
        {
          "value": "🚊",
          "searchTerm": [],
        },
        {
          "value": "🚝",
          "searchTerm": [],
        },
        {
          "value": "🚞",
          "searchTerm": [],
        },
        {
          "value": "🚋",
          "searchTerm": [],
        },
        {
          "value": "🚌",
          "searchTerm": [],
        },
        {
          "value": "🚍",
          "searchTerm": [],
        },
        {
          "value": "🚎",
          "searchTerm": [],
        },
        {
          "value": "🚐",
          "searchTerm": [],
        },
        {
          "value": "🚑",
          "searchTerm": [],
        },
        {
          "value": "🚒",
          "searchTerm": [],
        },
        {
          "value": "🚓",
          "searchTerm": [],
        },
        {
          "value": "🚔",
          "searchTerm": [],
        },
        {
          "value": "🚕",
          "searchTerm": [],
        },
        {
          "value": "🚖",
          "searchTerm": [],
        },
        {
          "value": "🚗",
          "searchTerm": [],
        },
        {
          "value": "🚘",
          "searchTerm": [],
        },
        {
          "value": "🚙",
          "searchTerm": [],
        },
        {
          "value": "🛻",
          "searchTerm": [],
        },
        {
          "value": "🚚",
          "searchTerm": [],
        },
        {
          "value": "🚛",
          "searchTerm": [],
        },
        {
          "value": "🚜",
          "searchTerm": [],
        },
        {
          "value": "🏎️",
          "searchTerm": [],
        },
        {
          "value": "🏍️",
          "searchTerm": [],
        },
        {
          "value": "🛵",
          "searchTerm": [],
        },
        {
          "value": "🦽",
          "searchTerm": [],
        },
        {
          "value": "🦼",
          "searchTerm": [],
        },
        {
          "value": "🛺",
          "searchTerm": [],
        },
        {
          "value": "🚲",
          "searchTerm": [],
        },
        {
          "value": "🛴",
          "searchTerm": [],
        },
        {
          "value": "🛹",
          "searchTerm": [],
        },
        {
          "value": "🛼",
          "searchTerm": [],
        },
        {
          "value": "🚏",
          "searchTerm": [],
        },
        {
          "value": "🛣️",
          "searchTerm": [],
        },
        {
          "value": "🛤️",
          "searchTerm": [],
        },
        {
          "value": "🛢️",
          "searchTerm": [],
        },
        {
          "value": "⛽",
          "searchTerm": [],
        },
        {
          "value": "🛞",
          "searchTerm": [],
        },
        {
          "value": "🚨",
          "searchTerm": [],
        },
        {
          "value": "🚥",
          "searchTerm": [],
        },
        {
          "value": "🚦",
          "searchTerm": [],
        },
        {
          "value": "🛑",
          "searchTerm": [],
        },
        {
          "value": "🚧",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Voyages aériens et maritimes",
      "emoji": [
        {
          "value": "⚓",
          "searchTerm": [],
        },
        {
          "value": "🛟",
          "searchTerm": [],
        },
        {
          "value": "⛵",
          "searchTerm": [],
        },
        {
          "value": "🛶",
          "searchTerm": [],
        },
        {
          "value": "🚤",
          "searchTerm": [],
        },
        {
          "value": "🛳️",
          "searchTerm": [],
        },
        {
          "value": "⛴️",
          "searchTerm": [],
        },
        {
          "value": "🛥️",
          "searchTerm": [],
        },
        {
          "value": "🚢",
          "searchTerm": [],
        },
        {
          "value": "✈️",
          "searchTerm": [],
        },
        {
          "value": "🛩️",
          "searchTerm": [],
        },
        {
          "value": "🛫",
          "searchTerm": [],
        },
        {
          "value": "🛬",
          "searchTerm": [],
        },
        {
          "value": "🪂",
          "searchTerm": [],
        },
        {
          "value": "💺",
          "searchTerm": [],
        },
        {
          "value": "🚁",
          "searchTerm": [],
        },
        {
          "value": "🚟",
          "searchTerm": [],
        },
        {
          "value": "🚠",
          "searchTerm": [],
        },
        {
          "value": "🚡",
          "searchTerm": [],
        },
        {
          "value": "🛰️",
          "searchTerm": [],
        },
        {
          "value": "🚀",
          "searchTerm": [],
        },
        {
          "value": "🛸",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Habits et apparence",
      "emoji": [
        {
          "value": "🎀",
          "searchTerm": [],
        },
        {
          "value": "🎗️",
          "searchTerm": [],
        },
        {
          "value": "👓",
          "searchTerm": [],
        },
        {
          "value": "🕶️",
          "searchTerm": [],
        },
        {
          "value": "🥽",
          "searchTerm": [],
        },
        {
          "value": "🥼",
          "searchTerm": [],
        },
        {
          "value": "🦺",
          "searchTerm": [],
        },
        {
          "value": "👔",
          "searchTerm": [],
        },
        {
          "value": "👕",
          "searchTerm": [],
        },
        {
          "value": "👖",
          "searchTerm": [],
        },
        {
          "value": "🧣",
          "searchTerm": [],
        },
        {
          "value": "🧤",
          "searchTerm": [],
        },
        {
          "value": "🧥",
          "searchTerm": [],
        },
        {
          "value": "🧦",
          "searchTerm": [],
        },
        {
          "value": "👗",
          "searchTerm": [],
        },
        {
          "value": "👘",
          "searchTerm": [],
        },
        {
          "value": "🥻",
          "searchTerm": [],
        },
        {
          "value": "🩱",
          "searchTerm": [],
        },
        {
          "value": "🩲",
          "searchTerm": [],
        },
        {
          "value": "🩳",
          "searchTerm": [],
        },
        {
          "value": "👙",
          "searchTerm": [],
        },
        {
          "value": "👚",
          "searchTerm": [],
        },
        {
          "value": "👛",
          "searchTerm": [],
        },
        {
          "value": "👜",
          "searchTerm": [],
        },
        {
          "value": "👝",
          "searchTerm": [],
        },
        {
          "value": "🪭",
          "searchTerm": [],
        },
        {
          "value": "🛍️",
          "searchTerm": [],
        },
        {
          "value": "🎒",
          "searchTerm": [],
        },
        {
          "value": "🩴",
          "searchTerm": [],
        },
        {
          "value": "👞",
          "searchTerm": [],
        },
        {
          "value": "👟",
          "searchTerm": [],
        },
        {
          "value": "🥾",
          "searchTerm": [],
        },
        {
          "value": "🥿",
          "searchTerm": [],
        },
        {
          "value": "👠",
          "searchTerm": [],
        },
        {
          "value": "👡",
          "searchTerm": [],
        },
        {
          "value": "🩰",
          "searchTerm": [],
        },
        {
          "value": "👢",
          "searchTerm": [],
        },
        {
          "value": "👑",
          "searchTerm": [],
        },
        {
          "value": "👒",
          "searchTerm": [],
        },
        {
          "value": "🎩",
          "searchTerm": [],
        },
        {
          "value": "🎓",
          "searchTerm": [],
        },
        {
          "value": "🧢",
          "searchTerm": [],
        },
        {
          "value": "🪖",
          "searchTerm": [],
        },
        {
          "value": "⛑️",
          "searchTerm": [],
        },
        {
          "value": "📿",
          "searchTerm": [],
        },
        {
          "value": "💄",
          "searchTerm": [],
        },
        {
          "value": "🪮",
          "searchTerm": [],
        },
        {
          "value": "💍",
          "searchTerm": [],
        },
        {
          "value": "💎",
          "searchTerm": [],
        },
        {
          "value": "🦯",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Musique et bruits",
      "emoji": [
        {
          "value": "🔇",
          "searchTerm": [],
        },
        {
          "value": "🔈",
          "searchTerm": [],
        },
        {
          "value": "🔉",
          "searchTerm": [],
        },
        {
          "value": "🔊",
          "searchTerm": [],
        },
        {
          "value": "📢",
          "searchTerm": [],
        },
        {
          "value": "📣",
          "searchTerm": [],
        },
        {
          "value": "📯",
          "searchTerm": [],
        },
        {
          "value": "🔔",
          "searchTerm": [],
        },
        {
          "value": "🔕",
          "searchTerm": [],
        },
        {
          "value": "🎼",
          "searchTerm": [],
        },
        {
          "value": "🎵",
          "searchTerm": [],
        },
        {
          "value": "🎶",
          "searchTerm": [],
        },
        {
          "value": "🎙️",
          "searchTerm": [],
        },
        {
          "value": "🎚️",
          "searchTerm": [],
        },
        {
          "value": "🎛️",
          "searchTerm": [],
        },
        {
          "value": "🎤",
          "searchTerm": [],
        },
        {
          "value": "🎧",
          "searchTerm": [],
        },
        {
          "value": "📻",
          "searchTerm": [],
        },
        {
          "value": "🎷",
          "searchTerm": [],
        },
        {
          "value": "🪗",
          "searchTerm": [],
        },
        {
          "value": "🎸",
          "searchTerm": [],
        },
        {
          "value": "🎹",
          "searchTerm": [],
        },
        {
          "value": "🎺",
          "searchTerm": [],
        },
        {
          "value": "🎻",
          "searchTerm": [],
        },
        {
          "value": "🪕",
          "searchTerm": [],
        },
        {
          "value": "🪈",
          "searchTerm": [],
        },
        {
          "value": "🥁",
          "searchTerm": [],
        },
        {
          "value": "🪘",
          "searchTerm": [],
        },
        {
          "value": "🪇",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Technologies",
      "emoji": [
        {
          "value": "📱",
          "searchTerm": [],
        },
        {
          "value": "📲",
          "searchTerm": [],
        },
        {
          "value": "☎️",
          "searchTerm": [],
        },
        {
          "value": "📞",
          "searchTerm": [],
        },
        {
          "value": "📟",
          "searchTerm": [],
        },
        {
          "value": "📠",
          "searchTerm": [],
        },
        {
          "value": "🔋",
          "searchTerm": [],
        },
        {
          "value": "🪫",
          "searchTerm": [],
        },
        {
          "value": "🔌",
          "searchTerm": [],
        },
        {
          "value": "💻",
          "searchTerm": [],
        },
        {
          "value": "🖥️",
          "searchTerm": [],
        },
        {
          "value": "🖨️",
          "searchTerm": [],
        },
        {
          "value": "⌨️",
          "searchTerm": [],
        },
        {
          "value": "🖱️",
          "searchTerm": [],
        },
        {
          "value": "🖲️",
          "searchTerm": [],
        },
        {
          "value": "💽",
          "searchTerm": [],
        },
        {
          "value": "💾",
          "searchTerm": [],
        },
        {
          "value": "💿",
          "searchTerm": [],
        },
        {
          "value": "📀",
          "searchTerm": [],
        },
        {
          "value": "🎥",
          "searchTerm": [],
        },
        {
          "value": "🎞️",
          "searchTerm": [],
        },
        {
          "value": "📽️",
          "searchTerm": [],
        },
        {
          "value": "🎬",
          "searchTerm": [],
        },
        {
          "value": "📺",
          "searchTerm": [],
        },
        {
          "value": "📷",
          "searchTerm": [],
        },
        {
          "value": "📸",
          "searchTerm": [],
        },
        {
          "value": "📹",
          "searchTerm": [],
        },
        {
          "value": "📼",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Bureau",
      "emoji": [
        {
          "value": "📔",
          "searchTerm": [],
        },
        {
          "value": "📕",
          "searchTerm": [],
        },
        {
          "value": "📖",
          "searchTerm": [],
        },
        {
          "value": "📗",
          "searchTerm": [],
        },
        {
          "value": "📘",
          "searchTerm": [],
        },
        {
          "value": "📙",
          "searchTerm": [],
        },
        {
          "value": "📚",
          "searchTerm": [],
        },
        {
          "value": "📓",
          "searchTerm": [],
        },
        {
          "value": "📒",
          "searchTerm": [],
        },
        {
          "value": "📃",
          "searchTerm": [],
        },
        {
          "value": "📜",
          "searchTerm": [],
        },
        {
          "value": "📄",
          "searchTerm": [],
        },
        {
          "value": "📰",
          "searchTerm": [],
        },
        {
          "value": "🗞️",
          "searchTerm": [],
        },
        {
          "value": "📑",
          "searchTerm": [],
        },
        {
          "value": "🔖",
          "searchTerm": [],
        },
        {
          "value": "🏷️",
          "searchTerm": [],
        },
        {
          "value": "✉️",
          "searchTerm": [],
        },
        {
          "value": "📧",
          "searchTerm": [],
        },
        {
          "value": "📨",
          "searchTerm": [],
        },
        {
          "value": "📩",
          "searchTerm": [],
        },
        {
          "value": "📤",
          "searchTerm": [],
        },
        {
          "value": "📥",
          "searchTerm": [],
        },
        {
          "value": "📦",
          "searchTerm": [],
        },
        {
          "value": "📫",
          "searchTerm": [],
        },
        {
          "value": "📪",
          "searchTerm": [],
        },
        {
          "value": "📬",
          "searchTerm": [],
        },
        {
          "value": "📭",
          "searchTerm": [],
        },
        {
          "value": "📮",
          "searchTerm": [],
        },
        {
          "value": "🗳️",
          "searchTerm": [],
        },
        {
          "value": "✏️",
          "searchTerm": [],
        },
        {
          "value": "✒️",
          "searchTerm": [],
        },
        {
          "value": "🖋️",
          "searchTerm": [],
        },
        {
          "value": "🖊️",
          "searchTerm": [],
        },
        {
          "value": "🖌️",
          "searchTerm": [],
        },
        {
          "value": "🖍️",
          "searchTerm": [],
        },
        {
          "value": "📝",
          "searchTerm": [],
        },
        {
          "value": "💼",
          "searchTerm": [],
        },
        {
          "value": "📁",
          "searchTerm": [],
        },
        {
          "value": "📂",
          "searchTerm": [],
        },
        {
          "value": "🗂️",
          "searchTerm": [],
        },
        {
          "value": "📅",
          "searchTerm": [],
        },
        {
          "value": "📆",
          "searchTerm": [],
        },
        {
          "value": "🗒️",
          "searchTerm": [],
        },
        {
          "value": "🗓️",
          "searchTerm": [],
        },
        {
          "value": "📇",
          "searchTerm": [],
        },
        {
          "value": "📈",
          "searchTerm": [],
        },
        {
          "value": "📉",
          "searchTerm": [],
        },
        {
          "value": "📊",
          "searchTerm": [],
        },
        {
          "value": "📋",
          "searchTerm": [],
        },
        {
          "value": "📌",
          "searchTerm": [],
        },
        {
          "value": "📍",
          "searchTerm": [],
        },
        {
          "value": "📎",
          "searchTerm": [],
        },
        {
          "value": "🖇️",
          "searchTerm": [],
        },
        {
          "value": "📏",
          "searchTerm": [],
        },
        {
          "value": "📐",
          "searchTerm": [],
        },
        {
          "value": "✂️",
          "searchTerm": [],
        },
        {
          "value": "🗃️",
          "searchTerm": [],
        },
        {
          "value": "🗄️",
          "searchTerm": [],
        },
        {
          "value": "🗑️",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Argent et temps",
      "emoji": [
        {
          "value": "⌛",
          "searchTerm": [],
        },
        {
          "value": "⏳",
          "searchTerm": [],
        },
        {
          "value": "⌚",
          "searchTerm": [],
        },
        {
          "value": "⏰",
          "searchTerm": [],
        },
        {
          "value": "⏱️",
          "searchTerm": [],
        },
        {
          "value": "⏲️",
          "searchTerm": [],
        },
        {
          "value": "🕰️",
          "searchTerm": [],
        },
        {
          "value": "🕛",
          "searchTerm": [],
        },
        {
          "value": "🕧",
          "searchTerm": [],
        },
        {
          "value": "🕐",
          "searchTerm": [],
        },
        {
          "value": "🕜",
          "searchTerm": [],
        },
        {
          "value": "🕑",
          "searchTerm": [],
        },
        {
          "value": "🕝",
          "searchTerm": [],
        },
        {
          "value": "🕒",
          "searchTerm": [],
        },
        {
          "value": "🕞",
          "searchTerm": [],
        },
        {
          "value": "🕓",
          "searchTerm": [],
        },
        {
          "value": "🕟",
          "searchTerm": [],
        },
        {
          "value": "🕔",
          "searchTerm": [],
        },
        {
          "value": "🕠",
          "searchTerm": [],
        },
        {
          "value": "🕕",
          "searchTerm": [],
        },
        {
          "value": "🕡",
          "searchTerm": [],
        },
        {
          "value": "🕖",
          "searchTerm": [],
        },
        {
          "value": "🕢",
          "searchTerm": [],
        },
        {
          "value": "🕗",
          "searchTerm": [],
        },
        {
          "value": "🕣",
          "searchTerm": [],
        },
        {
          "value": "🕘",
          "searchTerm": [],
        },
        {
          "value": "🕤",
          "searchTerm": [],
        },
        {
          "value": "🕙",
          "searchTerm": [],
        },
        {
          "value": "🕥",
          "searchTerm": [],
        },
        {
          "value": "🕚",
          "searchTerm": [],
        },
        {
          "value": "🕦",
          "searchTerm": [],
        },
        {
          "value": "🧮",
          "searchTerm": [],
        },
        {
          "value": "💰",
          "searchTerm": [],
        },
        {
          "value": "🪙",
          "searchTerm": [],
        },
        {
          "value": "💴",
          "searchTerm": [],
        },
        {
          "value": "💵",
          "searchTerm": [],
        },
        {
          "value": "💶",
          "searchTerm": [],
        },
        {
          "value": "💷",
          "searchTerm": [],
        },
        {
          "value": "💸",
          "searchTerm": [],
        },
        {
          "value": "💳",
          "searchTerm": [],
        },
        {
          "value": "🧾",
          "searchTerm": [],
        },
        {
          "value": "💹",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Outils",
      "emoji": [
        {
          "value": "💣",
          "searchTerm": [],
        },
        {
          "value": "🧳",
          "searchTerm": [],
        },
        {
          "value": "🌡️",
          "searchTerm": [],
        },
        {
          "value": "🧸",
          "searchTerm": [],
        },
        {
          "value": "🧶",
          "searchTerm": [],
        },
        {
          "value": "🪢",
          "searchTerm": [],
        },
        {
          "value": "🔍",
          "searchTerm": [],
        },
        {
          "value": "🔎",
          "searchTerm": [],
        },
        {
          "value": "🕯️",
          "searchTerm": [],
        },
        {
          "value": "💡",
          "searchTerm": [],
        },
        {
          "value": "🔦",
          "searchTerm": [],
        },
        {
          "value": "🔒",
          "searchTerm": [],
        },
        {
          "value": "🔓",
          "searchTerm": [],
        },
        {
          "value": "🔏",
          "searchTerm": [],
        },
        {
          "value": "🔐",
          "searchTerm": [],
        },
        {
          "value": "🔑",
          "searchTerm": [],
        },
        {
          "value": "🗝️",
          "searchTerm": [],
        },
        {
          "value": "🔨",
          "searchTerm": [],
        },
        {
          "value": "🪓",
          "searchTerm": [],
        },
        {
          "value": "⛏️",
          "searchTerm": [],
        },
        {
          "value": "⚒️",
          "searchTerm": [],
        },
        {
          "value": "🛠️",
          "searchTerm": [],
        },
        {
          "value": "🗡️",
          "searchTerm": [],
        },
        {
          "value": "⚔️",
          "searchTerm": [],
        },
        {
          "value": "🪃",
          "searchTerm": [],
        },
        {
          "value": "🏹",
          "searchTerm": [],
        },
        {
          "value": "🛡️",
          "searchTerm": [],
        },
        {
          "value": "🪚",
          "searchTerm": [],
        },
        {
          "value": "🔧",
          "searchTerm": [],
        },
        {
          "value": "🪛",
          "searchTerm": [],
        },
        {
          "value": "🔩",
          "searchTerm": [],
        },
        {
          "value": "⚙️",
          "searchTerm": [],
        },
        {
          "value": "🗜️",
          "searchTerm": [],
        },
        {
          "value": "⚖️",
          "searchTerm": [],
        },
        {
          "value": "🔗",
          "searchTerm": [],
        },
        {
          "value": "⛓️",
          "searchTerm": [],
        },
        {
          "value": "🪝",
          "searchTerm": [],
        },
        {
          "value": "🧰",
          "searchTerm": [],
        },
        {
          "value": "🧲",
          "searchTerm": [],
        },
        {
          "value": "🪜",
          "searchTerm": [],
        },
        {
          "value": "⚗️",
          "searchTerm": [],
        },
        {
          "value": "🧪",
          "searchTerm": [],
        },
        {
          "value": "🧫",
          "searchTerm": [],
        },
        {
          "value": "🔬",
          "searchTerm": [],
        },
        {
          "value": "🔭",
          "searchTerm": [],
        },
        {
          "value": "📡",
          "searchTerm": [],
        },
        {
          "value": "💉",
          "searchTerm": [],
        },
        {
          "value": "🩹",
          "searchTerm": [],
        },
        {
          "value": "🩼",
          "searchTerm": [],
        },
        {
          "value": "🩺",
          "searchTerm": [],
        },
        {
          "value": "🩻",
          "searchTerm": [],
        },
        {
          "value": "🚪",
          "searchTerm": [],
        },
        {
          "value": "🪞",
          "searchTerm": [],
        },
        {
          "value": "🪟",
          "searchTerm": [],
        },
        {
          "value": "🛏️",
          "searchTerm": [],
        },
        {
          "value": "🛋️",
          "searchTerm": [],
        },
        {
          "value": "🪑",
          "searchTerm": [],
        },
        {
          "value": "🚽",
          "searchTerm": [],
        },
        {
          "value": "🪠",
          "searchTerm": [],
        },
        {
          "value": "🚿",
          "searchTerm": [],
        },
        {
          "value": "🛁",
          "searchTerm": [],
        },
        {
          "value": "🪤",
          "searchTerm": [],
        },
        {
          "value": "🪒",
          "searchTerm": [],
        },
        {
          "value": "🧴",
          "searchTerm": [],
        },
        {
          "value": "🧷",
          "searchTerm": [],
        },
        {
          "value": "🧹",
          "searchTerm": [],
        },
        {
          "value": "🧺",
          "searchTerm": [],
        },
        {
          "value": "🧻",
          "searchTerm": [],
        },
        {
          "value": "🪣",
          "searchTerm": [],
        },
        {
          "value": "🧼",
          "searchTerm": [],
        },
        {
          "value": "🫧",
          "searchTerm": [],
        },
        {
          "value": "🪥",
          "searchTerm": [],
        },
        {
          "value": "🧽",
          "searchTerm": [],
        },
        {
          "value": "🧯",
          "searchTerm": [],
        },
        {
          "value": "🛒",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Cœurs, formes et émotions",
      "emoji": [
        {
          "value": "💋",
          "searchTerm": [],
        },
        {
          "value": "💌",
          "searchTerm": [],
        },
        {
          "value": "💘",
          "searchTerm": [],
        },
        {
          "value": "💝",
          "searchTerm": [],
        },
        {
          "value": "💖",
          "searchTerm": [],
        },
        {
          "value": "💗",
          "searchTerm": [],
        },
        {
          "value": "💓",
          "searchTerm": [],
        },
        {
          "value": "💞",
          "searchTerm": [],
        },
        {
          "value": "💕",
          "searchTerm": [],
        },
        {
          "value": "💟",
          "searchTerm": [],
        },
        {
          "value": "❣️",
          "searchTerm": [],
        },
        {
          "value": "💔",
          "searchTerm": [],
        },
        {
          "value": "❤️‍🔥",
          "searchTerm": [],
        },
        {
          "value": "❤️‍🩹",
          "searchTerm": [],
        },
        {
          "value": "❤️",
          "searchTerm": [],
        },
        {
          "value": "🩷",
          "searchTerm": [],
        },
        {
          "value": "🧡",
          "searchTerm": [],
        },
        {
          "value": "💛",
          "searchTerm": [],
        },
        {
          "value": "💚",
          "searchTerm": [],
        },
        {
          "value": "💙",
          "searchTerm": [],
        },
        {
          "value": "🩵",
          "searchTerm": [],
        },
        {
          "value": "💜",
          "searchTerm": [],
        },
        {
          "value": "🤎",
          "searchTerm": [],
        },
        {
          "value": "🖤",
          "searchTerm": [],
        },
        {
          "value": "🩶",
          "searchTerm": [],
        },
        {
          "value": "🤍",
          "searchTerm": [],
        },
        {
          "value": "💯",
          "searchTerm": [],
        },
        {
          "value": "💢",
          "searchTerm": [],
        },
        {
          "value": "💥",
          "searchTerm": [],
        },
        {
          "value": "💦",
          "searchTerm": [],
        },
        {
          "value": "💨",
          "searchTerm": [],
        },
        {
          "value": "🕳️",
          "searchTerm": [],
        },
        {
          "value": "💬",
          "searchTerm": [],
        },
        {
          "value": "👁️‍🗨️",
          "searchTerm": [],
        },
        {
          "value": "🗨️",
          "searchTerm": [],
        },
        {
          "value": "🗯️",
          "searchTerm": [],
        },
        {
          "value": "💭",
          "searchTerm": [],
        },
        {
          "value": "💤",
          "searchTerm": [],
        },
        {
          "value": "🔴",
          "searchTerm": [],
        },
        {
          "value": "🟠",
          "searchTerm": [],
        },
        {
          "value": "🟡",
          "searchTerm": [],
        },
        {
          "value": "🟢",
          "searchTerm": [],
        },
        {
          "value": "🔵",
          "searchTerm": [],
        },
        {
          "value": "🟣",
          "searchTerm": [],
        },
        {
          "value": "🟤",
          "searchTerm": [],
        },
        {
          "value": "⚫",
          "searchTerm": [],
        },
        {
          "value": "⚪",
          "searchTerm": [],
        },
        {
          "value": "🟥",
          "searchTerm": [],
        },
        {
          "value": "🟧",
          "searchTerm": [],
        },
        {
          "value": "🟨",
          "searchTerm": [],
        },
        {
          "value": "🟩",
          "searchTerm": [],
        },
        {
          "value": "🟦",
          "searchTerm": [],
        },
        {
          "value": "🟪",
          "searchTerm": [],
        },
        {
          "value": "🟫",
          "searchTerm": [],
        },
        {
          "value": "⬜",
          "searchTerm": [],
        },
        {
          "value": "◼️",
          "searchTerm": [],
        },
        {
          "value": "◻️",
          "searchTerm": [],
        },
        {
          "value": "◾",
          "searchTerm": [],
        },
        {
          "value": "◽",
          "searchTerm": [],
        },
        {
          "value": "▪️",
          "searchTerm": [],
        },
        {
          "value": "▫️",
          "searchTerm": [],
        },
        {
          "value": "🔶",
          "searchTerm": [],
        },
        {
          "value": "🔷",
          "searchTerm": [],
        },
        {
          "value": "🔸",
          "searchTerm": [],
        },
        {
          "value": "🔹",
          "searchTerm": [],
        },
        {
          "value": "🔺",
          "searchTerm": [],
        },
        {
          "value": "🔻",
          "searchTerm": [],
        },
        {
          "value": "💠",
          "searchTerm": [],
        },
        {
          "value": "🔘",
          "searchTerm": [],
        },
        {
          "value": "🔳",
          "searchTerm": [],
        },
        {
          "value": "🔲",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Panneaux et symboles",
      "emoji": [
        {
          "value": "🛗",
          "searchTerm": [],
        },
        {
          "value": "🏧",
          "searchTerm": [],
        },
        {
          "value": "🚮",
          "searchTerm": [],
        },
        {
          "value": "🚰",
          "searchTerm": [],
        },
        {
          "value": "♿",
          "searchTerm": [],
        },
        {
          "value": "🚹",
          "searchTerm": [],
        },
        {
          "value": "🚺",
          "searchTerm": [],
        },
        {
          "value": "🚻",
          "searchTerm": [],
        },
        {
          "value": "🚼",
          "searchTerm": [],
        },
        {
          "value": "🚾",
          "searchTerm": [],
        },
        {
          "value": "🛂",
          "searchTerm": [],
        },
        {
          "value": "🛃",
          "searchTerm": [],
        },
        {
          "value": "🛄",
          "searchTerm": [],
        },
        {
          "value": "🛅",
          "searchTerm": [],
        },
        {
          "value": "⚠️",
          "searchTerm": [],
        },
        {
          "value": "🚸",
          "searchTerm": [],
        },
        {
          "value": "⛔",
          "searchTerm": [],
        },
        {
          "value": "🚫",
          "searchTerm": [],
        },
        {
          "value": "🚳",
          "searchTerm": [],
        },
        {
          "value": "🚭",
          "searchTerm": [],
        },
        {
          "value": "🚯",
          "searchTerm": [],
        },
        {
          "value": "🚱",
          "searchTerm": [],
        },
        {
          "value": "🚷",
          "searchTerm": [],
        },
        {
          "value": "📵",
          "searchTerm": [],
        },
        {
          "value": "🔞",
          "searchTerm": [],
        },
        {
          "value": "☢️",
          "searchTerm": [],
        },
        {
          "value": "☣️",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Flèches et icônes",
      "emoji": [
        {
          "value": "⬆️",
          "searchTerm": [],
        },
        {
          "value": "↗️",
          "searchTerm": [],
        },
        {
          "value": "➡️",
          "searchTerm": [],
        },
        {
          "value": "↘️",
          "searchTerm": [],
        },
        {
          "value": "⬇️",
          "searchTerm": [],
        },
        {
          "value": "↙️",
          "searchTerm": [],
        },
        {
          "value": "⬅️",
          "searchTerm": [],
        },
        {
          "value": "↖️",
          "searchTerm": [],
        },
        {
          "value": "↕️",
          "searchTerm": [],
        },
        {
          "value": "↔️",
          "searchTerm": [],
        },
        {
          "value": "↩️",
          "searchTerm": [],
        },
        {
          "value": "↪️",
          "searchTerm": [],
        },
        {
          "value": "⤴️",
          "searchTerm": [],
        },
        {
          "value": "⤵️",
          "searchTerm": [],
        },
        {
          "value": "🔃",
          "searchTerm": [],
        },
        {
          "value": "🔄",
          "searchTerm": [],
        },
        {
          "value": "🔙",
          "searchTerm": [],
        },
        {
          "value": "🔚",
          "searchTerm": [],
        },
        {
          "value": "🔛",
          "searchTerm": [],
        },
        {
          "value": "🔜",
          "searchTerm": [],
        },
        {
          "value": "🔝",
          "searchTerm": [],
        },
        {
          "value": "🔀",
          "searchTerm": [],
        },
        {
          "value": "🔁",
          "searchTerm": [],
        },
        {
          "value": "🔂",
          "searchTerm": [],
        },
        {
          "value": "▶️",
          "searchTerm": [],
        },
        {
          "value": "⏩",
          "searchTerm": [],
        },
        {
          "value": "⏭️",
          "searchTerm": [],
        },
        {
          "value": "⏯️",
          "searchTerm": [],
        },
        {
          "value": "◀️",
          "searchTerm": [],
        },
        {
          "value": "⏪",
          "searchTerm": [],
        },
        {
          "value": "⏮️",
          "searchTerm": [],
        },
        {
          "value": "🔼",
          "searchTerm": [],
        },
        {
          "value": "⏫",
          "searchTerm": [],
        },
        {
          "value": "🔽",
          "searchTerm": [],
        },
        {
          "value": "⏬",
          "searchTerm": [],
        },
        {
          "value": "⏸️",
          "searchTerm": [],
        },
        {
          "value": "⏹️",
          "searchTerm": [],
        },
        {
          "value": "⏺️",
          "searchTerm": [],
        },
        {
          "value": "⏏️",
          "searchTerm": [],
        },
        {
          "value": "🎦",
          "searchTerm": [],
        },
        {
          "value": "🔅",
          "searchTerm": [],
        },
        {
          "value": "🔆",
          "searchTerm": [],
        },
        {
          "value": "🛜",
          "searchTerm": [],
        },
        {
          "value": "📶",
          "searchTerm": [],
        },
        {
          "value": "📳",
          "searchTerm": [],
        },
        {
          "value": "📴",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Identités et croyances",
      "emoji": [
        {
          "value": "🛐",
          "searchTerm": [],
        },
        {
          "value": "🕉️",
          "searchTerm": [],
        },
        {
          "value": "✡️",
          "searchTerm": [],
        },
        {
          "value": "☸️",
          "searchTerm": [],
        },
        {
          "value": "☯️",
          "searchTerm": [],
        },
        {
          "value": "✝️",
          "searchTerm": [],
        },
        {
          "value": "☦️",
          "searchTerm": [],
        },
        {
          "value": "☪️",
          "searchTerm": [],
        },
        {
          "value": "🪯",
          "searchTerm": [],
        },
        {
          "value": "☮️",
          "searchTerm": [],
        },
        {
          "value": "🕎",
          "searchTerm": [],
        },
        {
          "value": "🔯",
          "searchTerm": [],
        },
        {
          "value": "♈",
          "searchTerm": [],
        },
        {
          "value": "♉",
          "searchTerm": [],
        },
        {
          "value": "♊",
          "searchTerm": [],
        },
        {
          "value": "♋",
          "searchTerm": [],
        },
        {
          "value": "♌",
          "searchTerm": [],
        },
        {
          "value": "♍",
          "searchTerm": [],
        },
        {
          "value": "♎",
          "searchTerm": [],
        },
        {
          "value": "♏",
          "searchTerm": [],
        },
        {
          "value": "♐",
          "searchTerm": [],
        },
        {
          "value": "♑",
          "searchTerm": [],
        },
        {
          "value": "♒",
          "searchTerm": [],
        },
        {
          "value": "♓",
          "searchTerm": [],
        },
        {
          "value": "⛎",
          "searchTerm": [],
        },
        {
          "value": "♀️",
          "searchTerm": [],
        },
        {
          "value": "♂️",
          "searchTerm": [],
        },
        {
          "value": "⚧️",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Alphanumérique",
      "emoji": [
        {
          "value": "✖️",
          "searchTerm": [],
        },
        {
          "value": "➕",
          "searchTerm": [],
        },
        {
          "value": "➖",
          "searchTerm": [],
        },
        {
          "value": "➗",
          "searchTerm": [],
        },
        {
          "value": "🟰",
          "searchTerm": [],
        },
        {
          "value": "♾️",
          "searchTerm": [],
        },
        {
          "value": "‼️",
          "searchTerm": [],
        },
        {
          "value": "⁉️",
          "searchTerm": [],
        },
        {
          "value": "❓",
          "searchTerm": [],
        },
        {
          "value": "❔",
          "searchTerm": [],
        },
        {
          "value": "❕",
          "searchTerm": [],
        },
        {
          "value": "❗",
          "searchTerm": [],
        },
        {
          "value": "〰️",
          "searchTerm": [],
        },
        {
          "value": "💱",
          "searchTerm": [],
        },
        {
          "value": "💲",
          "searchTerm": [],
        },
        {
          "value": "#️⃣",
          "searchTerm": [],
        },
        {
          "value": "*️⃣",
          "searchTerm": [],
        },
        {
          "value": "0️⃣",
          "searchTerm": [],
        },
        {
          "value": "1️⃣",
          "searchTerm": [],
        },
        {
          "value": "2️⃣",
          "searchTerm": [],
        },
        {
          "value": "3️⃣",
          "searchTerm": [],
        },
        {
          "value": "4️⃣",
          "searchTerm": [],
        },
        {
          "value": "5️⃣",
          "searchTerm": [],
        },
        {
          "value": "6️⃣",
          "searchTerm": [],
        },
        {
          "value": "7️⃣",
          "searchTerm": [],
        },
        {
          "value": "8️⃣",
          "searchTerm": [],
        },
        {
          "value": "9️⃣",
          "searchTerm": [],
        },
        {
          "value": "🔟",
          "searchTerm": [],
        },
        {
          "value": "🔠",
          "searchTerm": [],
        },
        {
          "value": "🔡",
          "searchTerm": [],
        },
        {
          "value": "🔢",
          "searchTerm": [],
        },
        {
          "value": "🔣",
          "searchTerm": [],
        },
        {
          "value": "🔤",
          "searchTerm": [],
        },
        {
          "value": "🅰️",
          "searchTerm": [],
        },
        {
          "value": "🆎",
          "searchTerm": [],
        },
        {
          "value": "🅱️",
          "searchTerm": [],
        },
        {
          "value": "🆑",
          "searchTerm": [],
        },
        {
          "value": "🆒",
          "searchTerm": [],
        },
        {
          "value": "🆓",
          "searchTerm": [],
        },
        {
          "value": "ℹ️",
          "searchTerm": [],
        },
        {
          "value": "🆔",
          "searchTerm": [],
        },
        {
          "value": "Ⓜ️",
          "searchTerm": [],
        },
        {
          "value": "🆕",
          "searchTerm": [],
        },
        {
          "value": "🆖",
          "searchTerm": [],
        },
        {
          "value": "🅾️",
          "searchTerm": [],
        },
        {
          "value": "🆗",
          "searchTerm": [],
        },
        {
          "value": "🆘",
          "searchTerm": [],
        },
        {
          "value": "🆙",
          "searchTerm": [],
        },
        {
          "value": "🆚",
          "searchTerm": [],
        },
        {
          "value": "🈁",
          "searchTerm": [],
        },
        {
          "value": "🈂️",
          "searchTerm": [],
        },
        {
          "value": "🈷️",
          "searchTerm": [],
        },
        {
          "value": "🈶",
          "searchTerm": [],
        },
        {
          "value": "🈯",
          "searchTerm": [],
        },
        {
          "value": "🉐",
          "searchTerm": [],
        },
        {
          "value": "🈹",
          "searchTerm": [],
        },
        {
          "value": "🈚",
          "searchTerm": [],
        },
        {
          "value": "🈲",
          "searchTerm": [],
        },
        {
          "value": "🉑",
          "searchTerm": [],
        },
        {
          "value": "🈸",
          "searchTerm": [],
        },
        {
          "value": "🈴",
          "searchTerm": [],
        },
        {
          "value": "🈳",
          "searchTerm": [],
        },
        {
          "value": "㊗️",
          "searchTerm": [],
        },
        {
          "value": "㊙️",
          "searchTerm": [],
        },
        {
          "value": "🈺",
          "searchTerm": [],
        },
        {
          "value": "🈵",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Autres symboles",
      "emoji": [
        {
          "value": "⚕️",
          "searchTerm": [],
        },
        {
          "value": "♻️",
          "searchTerm": [],
        },
        {
          "value": "⚜️",
          "searchTerm": [],
        },
        {
          "value": "📛",
          "searchTerm": [],
        },
        {
          "value": "🔰",
          "searchTerm": [],
        },
        {
          "value": "⭕",
          "searchTerm": [],
        },
        {
          "value": "✅",
          "searchTerm": [],
        },
        {
          "value": "☑️",
          "searchTerm": [],
        },
        {
          "value": "✔️",
          "searchTerm": [],
        },
        {
          "value": "❌",
          "searchTerm": [],
        },
        {
          "value": "❎",
          "searchTerm": [],
        },
        {
          "value": "➰",
          "searchTerm": [],
        },
        {
          "value": "➿",
          "searchTerm": [],
        },
        {
          "value": "〽️",
          "searchTerm": [],
        },
        {
          "value": "✳️",
          "searchTerm": [],
        },
        {
          "value": "✴️",
          "searchTerm": [],
        },
        {
          "value": "❇️",
          "searchTerm": [],
        },
        {
          "value": "©️",
          "searchTerm": [],
        },
        {
          "value": "®️",
          "searchTerm": [],
        },
        {
          "value": "™️",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Couleur et identité",
      "emoji": [
        {
          "value": "🏁",
          "searchTerm": [],
        },
        {
          "value": "🚩",
          "searchTerm": [],
        },
        {
          "value": "🎌",
          "searchTerm": [],
        },
        {
          "value": "🏴",
          "searchTerm": [],
        },
        {
          "value": "🏳️",
          "searchTerm": [],
        },
        {
          "value": "🏳️‍🌈",
          "searchTerm": [],
        },
        {
          "value": "🏳️‍⚧️",
          "searchTerm": [],
        },
        {
          "value": "🏴‍☠️",
          "searchTerm": [],
        },
        {
          "value": "🇺🇳",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Afrique",
      "emoji": [
        {
          "value": "🇦🇴",
          "searchTerm": [],
        },
        {
          "value": "🇧🇫",
          "searchTerm": [],
        },
        {
          "value": "🇧🇮",
          "searchTerm": [],
        },
        {
          "value": "🇧🇯",
          "searchTerm": [],
        },
        {
          "value": "🇧🇼",
          "searchTerm": [],
        },
        {
          "value": "🇨🇩",
          "searchTerm": [],
        },
        {
          "value": "🇨🇫",
          "searchTerm": [],
        },
        {
          "value": "🇨🇬",
          "searchTerm": [],
        },
        {
          "value": "🇨🇮",
          "searchTerm": [],
        },
        {
          "value": "🇨🇲",
          "searchTerm": [],
        },
        {
          "value": "🇨🇻",
          "searchTerm": [],
        },
        {
          "value": "🇩🇯",
          "searchTerm": [],
        },
        {
          "value": "🇩🇿",
          "searchTerm": [],
        },
        {
          "value": "🇪🇬",
          "searchTerm": [],
        },
        {
          "value": "🇪🇭",
          "searchTerm": [],
        },
        {
          "value": "🇪🇷",
          "searchTerm": [],
        },
        {
          "value": "🇪🇹",
          "searchTerm": [],
        },
        {
          "value": "🇬🇦",
          "searchTerm": [],
        },
        {
          "value": "🇬🇭",
          "searchTerm": [],
        },
        {
          "value": "🇬🇲",
          "searchTerm": [],
        },
        {
          "value": "🇬🇳",
          "searchTerm": [],
        },
        {
          "value": "🇬🇶",
          "searchTerm": [],
        },
        {
          "value": "🇬🇼",
          "searchTerm": [],
        },
        {
          "value": "🇰🇪",
          "searchTerm": [],
        },
        {
          "value": "🇰🇲",
          "searchTerm": [],
        },
        {
          "value": "🇱🇷",
          "searchTerm": [],
        },
        {
          "value": "🇱🇸",
          "searchTerm": [],
        },
        {
          "value": "🇱🇾",
          "searchTerm": [],
        },
        {
          "value": "🇲🇦",
          "searchTerm": [],
        },
        {
          "value": "🇲🇬",
          "searchTerm": [],
        },
        {
          "value": "🇲🇱",
          "searchTerm": [],
        },
        {
          "value": "🇲🇷",
          "searchTerm": [],
        },
        {
          "value": "🇲🇺",
          "searchTerm": [],
        },
        {
          "value": "🇲🇼",
          "searchTerm": [],
        },
        {
          "value": "🇲🇿",
          "searchTerm": [],
        },
        {
          "value": "🇳🇦",
          "searchTerm": [],
        },
        {
          "value": "🇳🇪",
          "searchTerm": [],
        },
        {
          "value": "🇳🇬",
          "searchTerm": [],
        },
        {
          "value": "🇷🇼",
          "searchTerm": [],
        },
        {
          "value": "🇸🇨",
          "searchTerm": [],
        },
        {
          "value": "🇸🇩",
          "searchTerm": [],
        },
        {
          "value": "🇸🇱",
          "searchTerm": [],
        },
        {
          "value": "🇸🇳",
          "searchTerm": [],
        },
        {
          "value": "🇸🇴",
          "searchTerm": [],
        },
        {
          "value": "🇸🇸",
          "searchTerm": [],
        },
        {
          "value": "🇸🇿",
          "searchTerm": [],
        },
        {
          "value": "🇹🇩",
          "searchTerm": [],
        },
        {
          "value": "🇹🇬",
          "searchTerm": [],
        },
        {
          "value": "🇹🇳",
          "searchTerm": [],
        },
        {
          "value": "🇹🇿",
          "searchTerm": [],
        },
        {
          "value": "🇺🇬",
          "searchTerm": [],
        },
        {
          "value": "🇿🇦",
          "searchTerm": [],
        },
        {
          "value": "🇿🇲",
          "searchTerm": [],
        },
        {
          "value": "🇿🇼",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Les amériques",
      "emoji": [
        {
          "value": "🇦🇬",
          "searchTerm": [],
        },
        {
          "value": "🇦🇮",
          "searchTerm": [],
        },
        {
          "value": "🇦🇷",
          "searchTerm": [],
        },
        {
          "value": "🇦🇼",
          "searchTerm": [],
        },
        {
          "value": "🇧🇧",
          "searchTerm": [],
        },
        {
          "value": "🇧🇱",
          "searchTerm": [],
        },
        {
          "value": "🇧🇲",
          "searchTerm": [],
        },
        {
          "value": "🇧🇴",
          "searchTerm": [],
        },
        {
          "value": "🇧🇶",
          "searchTerm": [],
        },
        {
          "value": "🇧🇷",
          "searchTerm": [],
        },
        {
          "value": "🇧🇸",
          "searchTerm": [],
        },
        {
          "value": "🇧🇿",
          "searchTerm": [],
        },
        {
          "value": "🇨🇦",
          "searchTerm": [],
        },
        {
          "value": "🇨🇱",
          "searchTerm": [],
        },
        {
          "value": "🇨🇴",
          "searchTerm": [],
        },
        {
          "value": "🇨🇷",
          "searchTerm": [],
        },
        {
          "value": "🇨🇺",
          "searchTerm": [],
        },
        {
          "value": "🇨🇼",
          "searchTerm": [],
        },
        {
          "value": "🇩🇲",
          "searchTerm": [],
        },
        {
          "value": "🇩🇴",
          "searchTerm": [],
        },
        {
          "value": "🇪🇨",
          "searchTerm": [],
        },
        {
          "value": "🇫🇰",
          "searchTerm": [],
        },
        {
          "value": "🇬🇩",
          "searchTerm": [],
        },
        {
          "value": "🇬🇫",
          "searchTerm": [],
        },
        {
          "value": "🇬🇵",
          "searchTerm": [],
        },
        {
          "value": "🇬🇹",
          "searchTerm": [],
        },
        {
          "value": "🇬🇾",
          "searchTerm": [],
        },
        {
          "value": "🇭🇳",
          "searchTerm": [],
        },
        {
          "value": "🇭🇹",
          "searchTerm": [],
        },
        {
          "value": "🇯🇲",
          "searchTerm": [],
        },
        {
          "value": "🇰🇳",
          "searchTerm": [],
        },
        {
          "value": "🇰🇾",
          "searchTerm": [],
        },
        {
          "value": "🇱🇨",
          "searchTerm": [],
        },
        {
          "value": "🇲🇫",
          "searchTerm": [],
        },
        {
          "value": "🇲🇶",
          "searchTerm": [],
        },
        {
          "value": "🇲🇸",
          "searchTerm": [],
        },
        {
          "value": "🇲🇽",
          "searchTerm": [],
        },
        {
          "value": "🇳🇮",
          "searchTerm": [],
        },
        {
          "value": "🇵🇦",
          "searchTerm": [],
        },
        {
          "value": "🇵🇪",
          "searchTerm": [],
        },
        {
          "value": "🇵🇲",
          "searchTerm": [],
        },
        {
          "value": "🇵🇷",
          "searchTerm": [],
        },
        {
          "value": "🇵🇾",
          "searchTerm": [],
        },
        {
          "value": "🇸🇷",
          "searchTerm": [],
        },
        {
          "value": "🇸🇻",
          "searchTerm": [],
        },
        {
          "value": "🇸🇽",
          "searchTerm": [],
        },
        {
          "value": "🇹🇨",
          "searchTerm": [],
        },
        {
          "value": "🇹🇹",
          "searchTerm": [],
        },
        {
          "value": "🇺🇸",
          "searchTerm": [],
        },
        {
          "value": "🇺🇾",
          "searchTerm": [],
        },
        {
          "value": "🇻🇪",
          "searchTerm": [],
        },
        {
          "value": "🇻🇬",
          "searchTerm": [],
        },
        {
          "value": "🇻🇮",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Asie et Moyen-Orient",
      "emoji": [
        {
          "value": "🇦🇪",
          "searchTerm": [],
        },
        {
          "value": "🇦🇫",
          "searchTerm": [],
        },
        {
          "value": "🇦🇿",
          "searchTerm": [],
        },
        {
          "value": "🇧🇩",
          "searchTerm": [],
        },
        {
          "value": "🇧🇭",
          "searchTerm": [],
        },
        {
          "value": "🇧🇳",
          "searchTerm": [],
        },
        {
          "value": "🇧🇹",
          "searchTerm": [],
        },
        {
          "value": "🇨🇳",
          "searchTerm": [],
        },
        {
          "value": "🇭🇰",
          "searchTerm": [],
        },
        {
          "value": "🇮🇩",
          "searchTerm": [],
        },
        {
          "value": "🇮🇱",
          "searchTerm": [],
        },
        {
          "value": "🇮🇳",
          "searchTerm": [],
        },
        {
          "value": "🇮🇶",
          "searchTerm": [],
        },
        {
          "value": "🇮🇷",
          "searchTerm": [],
        },
        {
          "value": "🇯🇴",
          "searchTerm": [],
        },
        {
          "value": "🇯🇵",
          "searchTerm": [],
        },
        {
          "value": "🇰🇬",
          "searchTerm": [],
        },
        {
          "value": "🇰🇭",
          "searchTerm": [],
        },
        {
          "value": "🇰🇵",
          "searchTerm": [],
        },
        {
          "value": "🇰🇷",
          "searchTerm": [],
        },
        {
          "value": "🇰🇼",
          "searchTerm": [],
        },
        {
          "value": "🇰🇿",
          "searchTerm": [],
        },
        {
          "value": "🇱🇦",
          "searchTerm": [],
        },
        {
          "value": "🇱🇧",
          "searchTerm": [],
        },
        {
          "value": "🇱🇰",
          "searchTerm": [],
        },
        {
          "value": "🇲🇲",
          "searchTerm": [],
        },
        {
          "value": "🇲🇳",
          "searchTerm": [],
        },
        {
          "value": "🇲🇴",
          "searchTerm": [],
        },
        {
          "value": "🇲🇻",
          "searchTerm": [],
        },
        {
          "value": "🇲🇾",
          "searchTerm": [],
        },
        {
          "value": "🇳🇵",
          "searchTerm": [],
        },
        {
          "value": "🇴🇲",
          "searchTerm": [],
        },
        {
          "value": "🇵🇭",
          "searchTerm": [],
        },
        {
          "value": "🇵🇰",
          "searchTerm": [],
        },
        {
          "value": "🇵🇸",
          "searchTerm": [],
        },
        {
          "value": "🇶🇦",
          "searchTerm": [],
        },
        {
          "value": "🇷🇺",
          "searchTerm": [],
        },
        {
          "value": "🇸🇦",
          "searchTerm": [],
        },
        {
          "value": "🇸🇬",
          "searchTerm": [],
        },
        {
          "value": "🇸🇾",
          "searchTerm": [],
        },
        {
          "value": "🇹🇭",
          "searchTerm": [],
        },
        {
          "value": "🇹🇯",
          "searchTerm": [],
        },
        {
          "value": "🇹🇱",
          "searchTerm": [],
        },
        {
          "value": "🇹🇲",
          "searchTerm": [],
        },
        {
          "value": "🇹🇷",
          "searchTerm": [],
        },
        {
          "value": "🇹🇼",
          "searchTerm": [],
        },
        {
          "value": "🇺🇿",
          "searchTerm": [],
        },
        {
          "value": "🇻🇳",
          "searchTerm": [],
        },
        {
          "value": "🇾🇪",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Europe",
      "emoji": [
        {
          "value": "🇦🇩",
          "searchTerm": [],
        },
        {
          "value": "🇦🇱",
          "searchTerm": [],
        },
        {
          "value": "🇦🇲",
          "searchTerm": [],
        },
        {
          "value": "🇦🇹",
          "searchTerm": [],
        },
        {
          "value": "🇧🇦",
          "searchTerm": [],
        },
        {
          "value": "🇧🇪",
          "searchTerm": [],
        },
        {
          "value": "🇧🇬",
          "searchTerm": [],
        },
        {
          "value": "🇧🇾",
          "searchTerm": [],
        },
        {
          "value": "🇨🇭",
          "searchTerm": [],
        },
        {
          "value": "🇨🇾",
          "searchTerm": [],
        },
        {
          "value": "🇨🇿",
          "searchTerm": [],
        },
        {
          "value": "🇩🇪",
          "searchTerm": [],
        },
        {
          "value": "🇩🇰",
          "searchTerm": [],
        },
        {
          "value": "🇪🇦",
          "searchTerm": [],
        },
        {
          "value": "🇪🇪",
          "searchTerm": [],
        },
        {
          "value": "🇪🇸",
          "searchTerm": [],
        },
        {
          "value": "🇪🇺",
          "searchTerm": [],
        },
        {
          "value": "🇫🇮",
          "searchTerm": [],
        },
        {
          "value": "🇫🇷",
          "searchTerm": [],
        },
        {
          "value": "🇬🇧",
          "searchTerm": [],
        },
        {
          "value": "🇬🇪",
          "searchTerm": [],
        },
        {
          "value": "🇬🇬",
          "searchTerm": [],
        },
        {
          "value": "🇬🇮",
          "searchTerm": [],
        },
        {
          "value": "🇬🇷",
          "searchTerm": [],
        },
        {
          "value": "🇭🇷",
          "searchTerm": [],
        },
        {
          "value": "🇭🇺",
          "searchTerm": [],
        },
        {
          "value": "🇮🇪",
          "searchTerm": [],
        },
        {
          "value": "🇮🇲",
          "searchTerm": [],
        },
        {
          "value": "🇮🇸",
          "searchTerm": [],
        },
        {
          "value": "🇮🇹",
          "searchTerm": [],
        },
        {
          "value": "🇯🇪",
          "searchTerm": [],
        },
        {
          "value": "🇱🇮",
          "searchTerm": [],
        },
        {
          "value": "🇱🇹",
          "searchTerm": [],
        },
        {
          "value": "🇱🇺",
          "searchTerm": [],
        },
        {
          "value": "🇱🇻",
          "searchTerm": [],
        },
        {
          "value": "🇲🇨",
          "searchTerm": [],
        },
        {
          "value": "🇲🇩",
          "searchTerm": [],
        },
        {
          "value": "🇲🇪",
          "searchTerm": [],
        },
        {
          "value": "🇲🇰",
          "searchTerm": [],
        },
        {
          "value": "🇲🇹",
          "searchTerm": [],
        },
        {
          "value": "🇳🇱",
          "searchTerm": [],
        },
        {
          "value": "🇳🇴",
          "searchTerm": [],
        },
        {
          "value": "🇵🇱",
          "searchTerm": [],
        },
        {
          "value": "🇵🇹",
          "searchTerm": [],
        },
        {
          "value": "🇷🇴",
          "searchTerm": [],
        },
        {
          "value": "🇷🇸",
          "searchTerm": [],
        },
        {
          "value": "🇷🇺",
          "searchTerm": [],
        },
        {
          "value": "🇸🇪",
          "searchTerm": [],
        },
        {
          "value": "🇸🇮",
          "searchTerm": [],
        },
        {
          "value": "🇸🇰",
          "searchTerm": [],
        },
        {
          "value": "🇸🇲",
          "searchTerm": [],
        },
        {
          "value": "🇺🇦",
          "searchTerm": [],
        },
        {
          "value": "🇻🇦",
          "searchTerm": [],
        },
        {
          "value": "🇽🇰",
          "searchTerm": [],
        },
        {
          "value": "🏴󠁧󠁢󠁥󠁮󠁧󠁿",
          "searchTerm": [],
        },
        {
          "value": "🏴󠁧󠁢󠁳󠁣󠁴󠁿",
          "searchTerm": [],
        },
        {
          "value": "🏴󠁧󠁢󠁷󠁬󠁳󠁿",
          "searchTerm": [],
        },
      ],
    },
    {
      "name": "Océanie, nations et territoires insulaires",
      "emoji": [
        {
          "value": "🇦🇨",
          "searchTerm": [],
        },
        {
          "value": "🇦🇶",
          "searchTerm": [],
        },
        {
          "value": "🇦🇸",
          "searchTerm": [],
        },
        {
          "value": "🇦🇺",
          "searchTerm": [],
        },
        {
          "value": "🇦🇽",
          "searchTerm": [],
        },
        {
          "value": "🇧🇻",
          "searchTerm": [],
        },
        {
          "value": "🇨🇨",
          "searchTerm": [],
        },
        {
          "value": "🇨🇰",
          "searchTerm": [],
        },
        {
          "value": "🇨🇵",
          "searchTerm": [],
        },
        {
          "value": "🇨🇽",
          "searchTerm": [],
        },
        {
          "value": "🇩🇬",
          "searchTerm": [],
        },
        {
          "value": "🇫🇯",
          "searchTerm": [],
        },
        {
          "value": "🇫🇲",
          "searchTerm": [],
        },
        {
          "value": "🇬🇱",
          "searchTerm": [],
        },
        {
          "value": "🇬🇸",
          "searchTerm": [],
        },
        {
          "value": "🇬🇺",
          "searchTerm": [],
        },
        {
          "value": "🇭🇲",
          "searchTerm": [],
        },
        {
          "value": "🇮🇨",
          "searchTerm": [],
        },
        {
          "value": "🇮🇴",
          "searchTerm": [],
        },
        {
          "value": "🇰🇮",
          "searchTerm": [],
        },
        {
          "value": "🇲🇭",
          "searchTerm": [],
        },
        {
          "value": "🇲🇵",
          "searchTerm": [],
        },
        {
          "value": "🇳🇨",
          "searchTerm": [],
        },
        {
          "value": "🇳🇫",
          "searchTerm": [],
        },
        {
          "value": "🇳🇷",
          "searchTerm": [],
        },
        {
          "value": "🇳🇺",
          "searchTerm": [],
        },
        {
          "value": "🇳🇿",
          "searchTerm": [],
        },
        {
          "value": "🇵🇫",
          "searchTerm": [],
        },
        {
          "value": "🇵🇬",
          "searchTerm": [],
        },
        {
          "value": "🇵🇳",
          "searchTerm": [],
        },
        {
          "value": "🇵🇼",
          "searchTerm": [],
        },
        {
          "value": "🇷🇪",
          "searchTerm": [],
        },
        {
          "value": "🇸🇧",
          "searchTerm": [],
        },
        {
          "value": "🇸🇭",
          "searchTerm": [],
        },
        {
          "value": "🇸🇯",
          "searchTerm": [],
        },
        {
          "value": "🇸🇹",
          "searchTerm": [],
        },
        {
          "value": "🇹🇦",
          "searchTerm": [],
        },
        {
          "value": "🇹🇫",
          "searchTerm": [],
        },
        {
          "value": "🇹🇰",
          "searchTerm": [],
        },
        {
          "value": "🇹🇴",
          "searchTerm": [],
        },
        {
          "value": "🇹🇻",
          "searchTerm": [],
        },
        {
          "value": "🇺🇲",
          "searchTerm": [],
        },
        {
          "value": "🇻🇨",
          "searchTerm": [],
        },
        {
          "value": "🇻🇺",
          "searchTerm": [],
        },
        {
          "value": "🇼🇫",
          "searchTerm": [],
        },
        {
          "value": "🇼🇸",
          "searchTerm": [],
        },
        {
          "value": "🇾🇹",
          "searchTerm": [],
        },
      ],
    },
  ];

  int emojiIndex = 0;
  /*String text = "[";
  for (var i = 0; i < emoji.length; i++) {
    text += '{"name": "${emoji[i]["name"]}","emoji": [';
    for (var j = 0; j < emoji[i]["emoji"].length; j++) {
      text += '{"value": "${emoji[i]["emoji"][j]}", "searchTerm" : [],},';
    }
    text += "],},";
  }
  text += "];";
  log(text);*/

  return showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Material(
              color: Colors.transparent,
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      color: Theme.of(context).primaryColor),
                  height: MediaQuery.of(context).size.height / 2,
                  child: Column(
                    children: [
                      change
                          ? CustomButton(
                              color: Colors.red.withOpacity(.1),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              onPressed: () {
                                Navigator.pop(context, "");
                              },
                              child: const Text("Supprimer l'emoji",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)))
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 70,
                          child: ListView.builder(
                              itemCount: emoji.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: CustomButton(
                                      padding: EdgeInsets.zero,
                                      color: black(context).withOpacity(
                                          index == emojiIndex ? .2 : .05),
                                      onPressed: () {
                                        setState(() {
                                          emojiIndex = index;
                                        });
                                      },
                                      shape: const StadiumBorder(),
                                      child: Text(
                                          emoji[index]["emoji"].first["value"],
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                      Text(emoji[emojiIndex]["name"],
                          style: const TextStyle(
                              fontSize: 20,
                              fontFamily: "Nexa",
                              fontWeight: FontWeight.bold)),
                      Expanded(
                        child: GridView.builder(
                            itemCount: emoji[emojiIndex]["emoji"].length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 6),
                            itemBuilder: (BuildContext context, index2) {
                              return Center(
                                  child: SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CustomButton(
                                          splashColor:
                                              black(context).withOpacity(0.1),
                                          highlightColor:
                                              black(context).withOpacity(0.1),
                                          shape: const StadiumBorder(),
                                          onPressed: () async {
                                            Navigator.pop(
                                                context,
                                                emoji[emojiIndex]["emoji"]
                                                    [index2]["value"]);
                                            return emoji[emojiIndex]["emoji"]
                                                [index2]["value"];
                                          },
                                          child: Text(
                                              emoji[emojiIndex]["emoji"][index2]
                                                  ["value"],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 20)))));
                            }),
                      ),
                    ],
                  )));
        });
      });
}

Future<DocumentSnapshot?> choiceLocation(
    BuildContext context, Color color, String? folder) async {
  return await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 2),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: white(context),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20))),
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("location")
                    .where("folder", isNull: folder == null, isEqualTo: folder)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height / 2),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: snapshot.data!.size,
                        itemBuilder: (context, index) {
                          return CustomButton(
                              color: color.withOpacity(.1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onPressed: () async {
                                Navigator.pop(
                                    context,
                                    snapshot.data!.docs[index]["type"] == "file"
                                        ? snapshot.data!.docs[index]
                                        : await choiceLocation(context, color,
                                            snapshot.data!.docs[index].id));
                              },
                              child: Text(snapshot.data!.docs[index].get("nom"),
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: color)));
                        },
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ));
      });
}

List<Color> getColors(BuildContext context, PaletteGenerator palette) {
  late Color primaryColor, secondaryColor;
  if (MediaQuery.of(context).platformBrightness == Brightness.light &&
      palette.lightMutedColor != null) {
    primaryColor = palette.lightMutedColor!.color.withOpacity(.4);
    secondaryColor = palette.lightMutedColor!.color.withOpacity(.2);
  } else if (MediaQuery.of(context).platformBrightness == Brightness.dark &&
      palette.darkVibrantColor != null) {
    primaryColor = palette.darkVibrantColor!.color.withOpacity(.8);
    secondaryColor = palette.darkVibrantColor!.color.withOpacity(.5);
  } else if (palette.mutedColor != null) {
    primaryColor = palette.mutedColor!.color.withOpacity(
        MediaQuery.of(context).platformBrightness == Brightness.dark ? .8 : .3);
    secondaryColor = palette.mutedColor!.color.withOpacity(
        MediaQuery.of(context).platformBrightness == Brightness.dark
            ? .5
            : .15);
  } else {
    primaryColor = palette.paletteColors[2].color.withOpacity(.4);
    secondaryColor = palette.paletteColors[2].color.withOpacity(.2);
  }
  return [primaryColor, secondaryColor];
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

Size calculateTextSize({
  required String text,
  required TextStyle style,
  required BuildContext context,
}) {
  final double textScaleFactor = MediaQuery.of(context).textScaleFactor;

  final TextDirection textDirection = Directionality.of(context);

  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: textDirection,
    textScaleFactor: textScaleFactor,
  )..layout(minWidth: 0, maxWidth: double.infinity);

  return textPainter.size;
}

Future<String?> uploadFile(BuildContext context, XFile image, String id) async {
  firebase_storage.Reference firebaseStorageRef = firebase_storage
      .FirebaseStorage.instance
      .ref()
      .child('picture/$id/${DateTime.now()}');
  final metadata = firebase_storage.SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': image.path});

  firebase_storage.UploadTask uploadTask =
      firebaseStorageRef.putFile(File(image.path), metadata);

  // Attendre la fin de l'upload
  await uploadTask.whenComplete(() {});

  // Récupérer et retourner l'URL de téléchargement
  return await firebaseStorageRef.getDownloadURL();
}

Future<XFile?> showPicker(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Choisissez une option'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text('Prendre une photo'),
                onTap: () async {
                  XFile? image = await _imgFromCamera();
                  if (image != null) {
                    Navigator.pop(context, image);
                  }
                },
              ),
              Padding(padding: EdgeInsets.all(8.0)),
              GestureDetector(
                child: Text('Importer depuis la galerie'),
                onTap: () async {
                  XFile? image = await _imgFromGallery();
                  if (image != null) {
                    Navigator.pop(context, image);
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<XFile?> _imgFromCamera() async {
  final ImagePicker _picker = ImagePicker();
  return await _picker.pickImage(
    source: ImageSource.camera,
  );
}

Future<XFile?> _imgFromGallery() async {
  return await ImagePicker().pickImage(
    source: ImageSource.gallery,
  );

  // Utilisez le fichier comme vous le souhaitez
}
